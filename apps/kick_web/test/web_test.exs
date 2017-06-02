defmodule Kick.WebTest do
  use ExUnit.Case
  use Plug.Test

  alias Kick.Web

  @opts Web.init(queue: TestQueue)

  setup do
    TestQueue.clear()
    :ok
  end

  # TestQueue.enqueue!(IO, :inspect, [:ok])

  describe "GET /" do
    test "no jobs" do
      conn = conn(:get, "/")

      conn = Web.call(conn, @opts)

      assert conn.status == 200
    end

    @tag :pending
    test "many jobs"
    @tag :pending
    test "lots of jobs"
  end

  describe "GET /jobs/:id" do
    @tag :pending
    test "job not found"
    @tag :pending
    test "job details"
  end
end
