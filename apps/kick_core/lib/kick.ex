defmodule Kick do
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @otp_app  Keyword.fetch!(opts, :otp_app)
      @repo     Keyword.fetch!(opts, :repo)

      def otp_app, do: @otp_app
      def repo, do: @repo

      ## API callbacks

      def start_link(opts \\ []) do
        Kick.start_link(__MODULE__, opts)
      end

      def enqueue(mod, fun, args, opts \\ []) do
        Kick.enqueue(@repo, mod, fun, args, opts)
      end

      def enqueue!(mod, fun, args, opts \\ []) do
        Kick.enqueue!(@repo, mod, fun, args, opts)
      end

      def all, do: Kick.all(@repo)
      def get(id), do: Kick.get(@repo, id)
      def count, do: Kick.count(@repo)

      def clear, do: Kick.clear(@repo)

      def tick, do: Kick.Worker.tick(@repo)
    end
  end

  alias Kick.Worker
  alias Kick.Job

  import Ecto.Query

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

  def enqueue!(repo, mod, fun, args, opts \\ []) do
    {:ok, job} = enqueue(repo, mod, fun, args, opts)
    job
  end

  def all(repo) do
    Job
    |> order_by(asc: :run_at)
    |> repo.all()
  end

  def get(repo, id) do
    case repo.get(Job, id) do
      nil -> :error
      job -> {:ok, job}
    end
  end

  def count(repo) do
    repo.aggregate(Job, :count, :id)
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
