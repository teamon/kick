defmodule Testapp.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Testapp.Repo, []),
      supervisor(Testapp.Queue, []),
      Plug.Adapters.Cowboy.child_spec(:http, Testapp.Router, [], [port: 4004])
    ]

    opts = [strategy: :one_for_one, name: Testapp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
