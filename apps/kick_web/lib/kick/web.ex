defmodule Kick.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    jobs = queue(conn).all()
    render(conn, :jobs, [jobs])
  end

  get "/jobs/:id" do
    case queue(conn).get(id) do
      {:ok, job} ->
        runs =
          job.runs
          |> Enum.with_index()
          |> Enum.reverse()
        render(conn, :job, [job, runs])
      :error ->
        render(conn, :not_found)
    end
  end

  def call(conn, opts) do
    conn
    |> put_private(:kick, opts)
    |> super(opts)
  end

  defp queue(conn), do: conn.private.kick[:queue]

  ## RENDERING

  defmodule Templates do
    require EEx
    EEx.function_from_file :def, :layout, "#{__DIR__}/web/layout.html.eex", [:conn, :body]
    EEx.function_from_file :def, :jobs,   "#{__DIR__}/web/jobs.html.eex",   [:conn, :jobs]
    EEx.function_from_file :def, :job,    "#{__DIR__}/web/job.html.eex",    [:conn, :job, :runs]

    defp link(conn, label, to: to) do
      url = Enum.join(conn.script_name, "/") <> to_string(to)
      ~s|<a href="/#{url}">#{escape(label)}</a>|
    end

    defp escape(value), do: Plug.HTML.html_escape(value)

    defp modname("Elixir." <> name), do: name
    defp modname(atom), do: modname(to_string(atom))

    defp format_run({ex, trace}), do: Exception.format(:error, ex, trace)
    defp format_run(signal), do: Exception.format(:exit, signal, [])
  end

  defp render(conn, :not_found) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(404, "Not Found")
  end

  defp render(conn, tpl, args \\ []) do
    body = apply(Templates, tpl, [conn | args])
    body = apply(Templates, :layout, [conn, body])

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, body)
  end
end
