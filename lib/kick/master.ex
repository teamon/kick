defmodule Kick.Master do
  alias Kick.Worker
  alias Kick.Job

  def start_link(queue, _opts \\ []) do
    import Supervisor.Spec

    config = Application.get_env(queue.otp_app, queue, [])
    workers = config[:workers] || 10

    children = for i <- (1..workers) do
      worker(Worker, [queue], id: i)
    end

    Supervisor.start_link(children, strategy: :one_for_one, name: queue)
  end

  def enqueue(repo, mod, fun, args, opts \\ []) do
    repo.insert(new(mod, fun, args, opts))
  end

  def all(repo) do
    repo.all(Job)
  end

  def clear(repo) do
    repo.delete_all(Job)
  end

  defp new(mod, fun, args, opts) do
    %Job{
      mod: mod,
      fun: fun,
      args: args,
      run_at: opts[:at]
    }
  end
end
