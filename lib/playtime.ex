defmodule Nats.Playtime do
  def init() do
    {:ok, gnat} = Gnat.start_link(%{host: 'demo.nats.io', port: 4222})
    gnat
  end

  def listen() do
    receive do
      {:msg, %{body: body, topic: "app", reply_to: nil}} ->
        IO.puts(body)
    end

    listen()
  end
end
