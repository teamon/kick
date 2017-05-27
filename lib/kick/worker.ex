defmodule Kick.Worker do
  use GenServer

  import Ecto.Query
  require Logger

  alias Kick.Job

  @job_timeout 60_000
  @fetch_every 2_000

  defstruct queue: nil, repo: nil

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    Process.flag(:trap_exit, true)
    send self(), :fetch
    {:ok, %__MODULE__{queue: queue, repo: queue.repo}}
  end

  def handle_info(:fetch, %{repo: repo} = state) do
    case fetch(repo) do
      {:ok, :empty} ->
        Process.send_after self(), :fetch, @fetch_every
        {:noreply, state}
      {:ok, _} ->
        send self(), :fetch
        {:noreply, state}
      {:error, reason} ->
        {:stop, reason, state}
    end
  end

  defp fetch(repo) do
    repo.transaction(fn ->
      case get(repo) do
        nil -> :empty
        job -> execute(repo, job)
      end
    end, timeout: @job_timeout + 100)
  end

  defp get(repo) do
    Job
    |> where([j], j.run_at <= fragment("(NOW() AT TIME ZONE 'UTC')"))
    |> lock("FOR UPDATE SKIP LOCKED")
    |> limit(1)
    |> repo.one()
  end

  defp execute(repo, job) do
    Logger.info "#{label(job)} starting"
    pid = spawn_link(__MODULE__, :exec, [job.mod, job.fun, job.args])

    receive do
      {:EXIT, ^pid, :normal} ->
        Logger.info "#{label(job)} finished"
        pop(repo, job)
      {:EXIT, ^pid, reason} ->
        Logger.error "#{label(job)} failed"
        retry(repo, job, reason)
    after
      @job_timeout ->
        Logger.error "#{label(job)} timeout"
        retry(repo, job, {:timeout, @job_timeout})
    end
  end

  def exec(mod, fun, args) do
    apply(mod, fun, args)
  rescue
    ex -> Process.exit(self(), {:exception, ex, System.stacktrace()})
  end

  defp retry(repo, job, reason) do
    retries = length(job.runs)
    run_in = trunc(:math.pow(2, retries))
    run_at = DateTime.from_unix!(:os.system_time(:second) + run_in)

    Job
    |> where(id: ^job.id)
    |> repo.update_all(set: [run_at: run_at], push: [runs: reason])
  end

  defp pop(repo, job) do
    repo.delete(job)
  end

  def label(job), do: "Job ##{job.id} (#{job.mod}.#{job.fun})"
end
