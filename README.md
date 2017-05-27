# Kick

Simple job queue backed by PostgreSQL

## Installation

1. Add `kick` to dependencies

```elixir
def deps do
  [{:kick, "~> 0.1.0"}]
end
```

2. Generate migration

```bash
$ mix ecto.gen.migration setup_kick
```

```elixir
defmodule MyApp.Repo.Migrations.SetupKick do
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
```

3. Create a queue

```elixir
# lib/myapp/queue.ex

defmodule MyApp.Queue do
  use Kick, otp_app: :my_app, repo: MyApp.Repo
end

```

## Usage


```elixir
MyApp.Queue.enqueue Module, :function, [:arg, :ume, :nts]
```
