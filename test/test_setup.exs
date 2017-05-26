Application.put_env(:pq_test, TestQueue, [
  adapter: Ecto.Adapters.Postgres,
  hostname: "localhost",
  port: 5433,
  database: "pq_test",
  username: "teamon",
  password: "",
  pool_size: 10
])

defmodule TestQueue do
  use PQ, otp_app: :pq_test
end

# setup test queue repo
{:ok, _}    = Ecto.Adapters.Postgres.ensure_all_started(TestQueue, :temporary)
_           = Ecto.Adapters.Postgres.storage_down(TestQueue.config)
:ok         = Ecto.Adapters.Postgres.storage_up(TestQueue.config)
{:ok, _pid} = TestQueue.start_link

# migrate database
Code.require_file "test_migration.exs", __DIR__

:ok = Ecto.Migrator.up(TestQueue, 0, TestMigration, log: false)
