defmodule Example.Repo.Migrations.SetupKick do
  use Ecto.Migration

  def change do
    create table(:kick_jobs) do
      add :mod,   :binary
      add :fun,   :binary
      add :args,  :binary

      add :run_at, :utc_datetime, default: fragment("(NOW() AT TIME ZONE 'UTC')")
      add :runs, {:array, :binary}, default: []

      timestamps(type: :utc_datetime)
    end
  end
end
