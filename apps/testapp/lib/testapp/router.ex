defmodule Testapp.Router do
  use Plug.Router

  use Plug.Debugger, otp_app: :testapp
  plug Plug.Logger, log: :debug
  plug :match
  plug :dispatch

  forward "/kick", to: Kick.Web, init_opts: [queue: Testapp.Queue]

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
