defmodule TestMigration do
  use Ecto.Migration

  def change do
    create table(:pq_jobs) do
      add :mod,   :binary
      add :fun,   :binary
      add :args,  :binary

      add :run_at, :utc_datetime, default: "NOW()"

      timestamps(type: :utc_datetime)
    end
  end
end
