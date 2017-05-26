defmodule PQ do
  @moduledoc """
  Documentation for PQ.
  """

  defmacro __using__(opts \\ []) do
    quote do
      use Ecto.Repo, unquote(opts)

      ## API callbacks

      def enqueue(mod, fun, args, opts \\ []) do
        PQ.enqueue(__MODULE__, mod, fun, args, opts)
      end
    end
  end

  defmodule Job do
    use Ecto.Schema

    @timestamps_opts type: :utc_datetime

    schema "pq_jobs" do
      field :mod,   :binary
      field :fun,   :binary
      field :args,  :binary

      field :run_at, :utc_datetime

      timestamps()
    end
  end


  def enqueue(queue, mod, fun, args, opts \\ []) do
    
  end
end
