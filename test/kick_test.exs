defmodule KickTest do
  use ExUnit.Case

  defmodule Jobs do
    def job0 do
      send :exunit_current_test, :job0
    end
  end

  setup_all do
    Code.require_file("test_setup.exs", __DIR__)
    :ok
  end

  setup do
    Process.register(self(), :exunit_current_test)
    TestQueue.clear()

    :ok
  end

  test "enqueue job" do
    {:ok, _} = TestQueue.enqueue(Jobs, :job0, [])

    [job] = TestQueue.all()

    assert job.run_at <= DateTime.utc_now()
    assert job.mod == Jobs
    assert job.fun == :job0
    assert job.args == []
  end

  test "enqueue job in the future" do
    {:ok, at, _} = DateTime.from_iso8601("2038-01-01T12:01:59.000000Z")
    {:ok, _} = TestQueue.enqueue(Jobs, :job0, [], at: at)

    [job] = TestQueue.all()

    assert job.run_at == at
    assert job.mod == Jobs
    assert job.fun == :job0
    assert job.args == []
  end
end
