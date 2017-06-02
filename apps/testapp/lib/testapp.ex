defmodule Testapp do
  def hello do
    :world
  end

  def example do
    Testapp.Queue.enqueue(__MODULE__, :do_throw, [])
    Testapp.Queue.enqueue(__MODULE__, :do_raise, [])
    Testapp.Queue.enqueue(__MODULE__, :do_kill, [])
    Testapp.Queue.enqueue(__MODULE__, :do_exit, [])
    Testapp.Queue.enqueue(__MODULE__, :do_sub_raise, [])
  end

  def do_raise do
    raise "oops"
  end

  def do_throw do
    throw :oops
  end

  def do_kill do
    Process.exit(self(), :kill)
  end

  def do_exit do
    Process.exit(self(), :something)
  end

  def do_sub_raise do
    spawn_link fn ->
      raise "whoo"
    end

    receive do
      _ -> :ok
    end
  end
end
