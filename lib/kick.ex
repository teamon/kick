defmodule Kick do
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @otp_app  Keyword.fetch!(opts, :otp_app)
      @repo     Keyword.fetch!(opts, :repo)

      def otp_app, do: @otp_app
      def repo, do: @repo

      ## API callbacks

      def start_link(opts \\ []) do
        Kick.Master.start_link(__MODULE__, opts)
      end

      def enqueue(mod, fun, args, opts \\ []) do
        Kick.Master.enqueue(@repo, mod, fun, args, opts)
      end

      def all do
        Kick.Master.all(@repo)
      end

      def clear do
        Kick.Master.clear(@repo)
      end
    end
  end
end
