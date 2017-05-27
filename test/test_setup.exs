Application.put_env(:kick_test, TestRepo, [
  adapter: Ecto.Adapters.Postgres,
  hostname: "localhost",
  port: 5433,
  database: "kick_test",
  username: "teamon",
  password: "",
  pool_size: 10
])

Application.put_env(:kick_test, TestQueue, [
  workers: 2
])

defmodule TestRepo do
  use Ecto.Repo, otp_app: :kick_test
end

defmodule TestQueue do
  use Kick, otp_app: :kick_test, repo: TestRepo
end

# setup test queue repo
{:ok, _}  = Ecto.Adapters.Postgres.ensure_all_started(TestRepo, :temporary)
_         = Ecto.Adapters.Postgres.storage_down(TestRepo.config)
:ok       = Ecto.Adapters.Postgres.storage_up(TestRepo.config)
{:ok, _}  = TestRepo.start_link()

# migrate database
Code.require_file "test_migration.exs", __DIR__

:ok = Ecto.Migrator.up(TestRepo, 0, TestMigration, log: false)

# start queue
{:ok, _}  = TestQueue.start_link()
