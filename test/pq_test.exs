defmodule PQTest do
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
    :ok
  end

  test "enqueue job" do
    TestQueue.enqueue(Jobs, :job0, [])
  end
end
