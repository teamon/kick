defmodule PQ do
  @moduledoc """
  Documentation for PQ.
  """

  defmacro __using__(opts \\ []) do
    quote do
      use Ecto.Repo, unquote(opts)

      ## API callbacks

      def enqueue(mod, fun, args, opts \\ []), do:
        PQ.enqueue(__MODULE__, mod, fun, args, opts)

      def all, do: PQ.all(__MODULE__)
      def clear, do: PQ.clear(__MODULE__)
    end
  end

  defmodule Term do
    @behaviour Ecto.Type

    def type, do: :binary
    def cast(term), do: {:ok, term}
    def load(bin), do: {:ok, :erlang.binary_to_term(bin)}
    def dump(term), do: {:ok, :erlang.term_to_binary(term)}
  end

  defmodule Job do
    use Ecto.Schema

    @timestamps_opts type: :utc_datetime

    schema "pq_jobs" do
      field :mod,   Term
      field :fun,   Term
      field :args,  Term

      field :run_at, :utc_datetime, usec: false

      timestamps()
    end
  end

  def enqueue(queue, mod, fun, args, opts \\ []) do
    queue.insert(new(queue, mod, fun, args, opts))
  end

  def all(queue) do
    queue.all(Job)
  end

  def clear(queue) do
    queue.delete_all(Job)
  end

  defp new(queue, mod, fun, args, opts) do
    %Job{
      mod: mod,
      fun: fun,
      args: args,
      run_at: opts[:at]
    }
  end
end
