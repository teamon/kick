defmodule KickTest do
  use ExUnit.Case

  defmodule Jobs do
    def ok do
      send :exunit_current_test, :ok
    end

    def raise do
      raise "oops"
    end

    def throw do
      throw :oops
    end

    def kill do
      Process.exit(self(), :kill)
    end
  end

  setup do
    Process.register(self(), :exunit_current_test)
    TestQueue.clear()

    :ok
  end

  test "enqueue job" do
    {:ok, _} = TestQueue.enqueue(Jobs, :ok, [])

    [job] = TestQueue.all()

    assert job.run_at <= DateTime.utc_now()
    assert job.mod == Jobs
    assert job.fun == :ok
    assert job.args == []
  end

  test "enqueue job in the future" do
    {:ok, at, _} = DateTime.from_iso8601("2038-01-01T12:01:59.000000Z")
    {:ok, _} = TestQueue.enqueue(Jobs, :ok, [], at: at)

    [job] = TestQueue.all()

    assert job.run_at == at
    assert job.mod == Jobs
    assert job.fun == :ok
    assert job.args == []
  end

  test "run job: ok" do
    TestQueue.enqueue!(Jobs, :ok, [])
    TestQueue.tick()

    assert_receive :ok
    assert TestQueue.count() == 0
  end

  test "run job: raise" do
    job0 = TestQueue.enqueue!(Jobs, :raise, [])
    TestQueue.tick()

    [job1] = TestQueue.all()
    assert job1.run_at > job0.run_at
    assert job1.mod == job0.mod
    assert job1.fun == job0.fun
    assert job1.args == job0.args
    assert [{%RuntimeError{message: "oops"}, [{Jobs, :raise, _, _}|_]}] = job1.runs
  end

  test "run job: throw" do
    job0 = TestQueue.enqueue!(Jobs, :throw, [])
    TestQueue.tick()

    refute_receive :crash
    [job1] = TestQueue.all()
    assert job1.run_at > job0.run_at
    assert job1.mod == job0.mod
    assert job1.fun == job0.fun
    assert job1.args == job0.args
    assert [{{:nocatch, :oops}, [{Jobs, :throw, _, _}|_]}] = job1.runs
  end

  test "run job: kill" do
    job0 = TestQueue.enqueue!(Jobs, :kill, [])
    TestQueue.tick()

    [job1] = TestQueue.all()
    assert job1.run_at > job0.run_at
    assert job1.mod == job0.mod
    assert job1.fun == job0.fun
    assert job1.args == job0.args
    assert [:killed] = job1.runs
  end
end
