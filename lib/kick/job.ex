defmodule Kick.Term do
  @behaviour Ecto.Type

  def type, do: :binary
  def cast(term), do: {:ok, term}
  def load(bin), do: {:ok, :erlang.binary_to_term(bin)}
  def dump(term), do: {:ok, :erlang.term_to_binary(term)}
end

defmodule Kick.Job do
  use Ecto.Schema

  alias Kick.Term

  schema "kick_jobs" do
    field :mod,   Term
    field :fun,   Term
    field :args,  Term

    field :run_at, :utc_datetime
    field :runs, {:array, Term}

    timestamps(type: :utc_datetime)
  end
end
