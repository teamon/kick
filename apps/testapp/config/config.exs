use Mix.Config

config :logger,
  level: :debug

config :testapp, Testapp.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: "localhost",
  port: 5433,
  database: "kick_testapp",
  username: "teamon",
  password: "",
  pool_size: 10


config :testapp, :ecto_repos, [Testapp.Repo]
