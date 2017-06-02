defmodule Kick.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    jobs = queue(conn).all()
    render(conn, :index, jobs: jobs)
  end

  get "/jobs/:id" do
    case queue(conn).get(id) do
      {:ok, job} -> render(conn, :show, job: job)
      :error -> render(conn, :not_found)
    end
  end

  def call(conn, opts) do
    conn
    |> put_private(:kick, opts)
    |> super(opts)
  end

  defp queue(conn), do: conn.private.kick[:queue]

  ## RENDERING

  defp render(:layout, %{body: body}) do
    [
      """
      <html>
      <head>
        <title>Kick</title>
        <style>
          * { font-family: monospace; font-size: 1em; }
          table { border-collapse: collapse; }
          td,th { padding: 3px 5px; }
          td { border-top: 1px solid #eee; }
        </style>
      </head>
      <body>
      """,
      body,
      """
      </body>
      </html>
      """
    ]
  end

  defp render(:index, %{jobs: []}) do
    "No jobs"
  end
  defp render(:index, %{jobs: jobs, conn: conn}) do
    [
      """
      <table>
        <tr>
          <th>ID</th>
          <th>Module</th>
          <th>Function</th>
          <th>Args</th>
          <th>Run At</th>
          <th>Retries</th>
        </tr>
      """,
      for job <- jobs do
        [
          "<tr>",
            "<td>",
              link(conn, "##{job.id}", to: "/jobs/#{job.id}"),
            "</td>",
            "<td>", escape(modname(job.mod)), "</td>",
            "<td>", escape(inspect(job.fun)), "</td>",
            "<td>", escape(inspect(job.args)), "</td>",
            "<td>", escape(to_string(job.run_at)), "</td>",
            "<td>", escape(to_string(length(job.runs))), "</td>",
          "</tr>"
        ]
      end,
      """
      </table>
      """
    ]
  end

  defp render(:show, %{job: job, conn: conn}) do
    runs =
      job.runs
      |> Enum.with_index()
      |> Enum.reverse()

    [
      "<table>",
        "<tr><th>ID</th><td>",        "##{job.id}", "</td></tr>",
        "<tr><th>Module</th><td>",    escape(modname(job.mod)), "</td></tr>",
        "<tr><th>Function</th><td>",  escape(inspect(job.fun)), "</td></tr>",
        "<tr><th>Args</th><td>",      escape(inspect(job.args)), "</td></tr>",
        "<tr><th>Run At</th><td>",    escape(to_string(job.run_at)), "</td></tr>",
        "<tr><th>Retries</th><td>",   escape(to_string(length(job.runs))), "</td></tr>",
      "</table>",
      "<table>",
        "<tr><th>Run #</th><th>Stacktrace</th></tr>",
        for {run, i} <- runs do
          [
            "<tr>",
              "<th>#{i}</th>",
              "<td><pre>#{format_run(run)}</pre></td>",
            "</tr>"
          ]
        end,
      "</table>"
    ]
  end

  defp render(:not_found, _) do
    "Not Found"
  end

  defp render(conn, tpl, assigns) do
    assigns =
      assigns
      |> Keyword.put(:conn, conn)
      |> Map.new()

    assigns =
      assigns
      |> Map.put(:body, render(tpl, assigns))

    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, render(:layout, assigns))
  end

  defp format_run({ex, trace}) do
    Exception.format(:error, ex, trace)
    # inspect {ex, trace}
  end
  defp format_run(signal) do
    Exception.format(:exit, signal, [])
  end

  defp link(conn, label, to: to) do
    url = Enum.join(conn.script_name, "/") <> to_string(to)
    ~s|<a href="/#{url}">#{escape(label)}</a>|
  end

  defp escape(value), do: Plug.HTML.html_escape(value)

  defp modname("Elixir." <> name), do: name
  defp modname(atom), do: modname(to_string(atom))
end
