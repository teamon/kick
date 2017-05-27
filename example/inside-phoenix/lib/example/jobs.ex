defmodule Example.Jobs do
  def send_email(to, subject) do
    IO.inspect {:sending_email, to, subject}
  end

  def generate_invoices do
    IO.inspect :generate_invoices
    :timer.sleep(60_000)
  end
end
