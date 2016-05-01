defmodule Moongate.Tests.Helper do
  # Test constants
  def defaults do
    %{
      http_port: 7596,
      log_packets: true,
      login: "moongate",
      password: "test",
      tcp_port: 7593,
      timeout: 5000,
      udp_port: 7594,
      ws_port: 7595
    }
  end

  # Create a TCP socket connection to the local server.
  def connect(pid) do
    socket = Socket.TCP.connect! {"127.0.0.1", defaults.tcp_port}
  end

  # Cleanup data from last run
  def clean do
    clean({:user, defaults.login})
  end
  def clean({:user, account}) do
    results = Moongate.Db.UserQueries.find_by_email(account)

    if length(results) > 0 do
      Moongate.Db.UserQueries.delete(hd(results).id)
    end
  end

  def disconnect(socket) do
    socket |> Socket.close
  end

  def download(url) do
    {:ok, response} = :httpc.request(:get, {url, []}, [], [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = response
    body
  end

  # Wait for a packet and send a message to the parent process
  # when that packet is received. Bang expects an exact match.
  def expect_packet!(socket, expects, parent), do: expect_packet(socket, expects, parent, false)
  def expect_packet(socket, expects, parent), do: expect_packet(socket, expects, parent, true)
  def expect_packet(socket, expects, parent, allow_fuzzy) do
    spawn fn ->
      case socket |> Socket.Stream.recv! do
        response ->
          if defaults.log_packets do
            IO.puts "Client received packet: #{response}."
          end

          if (response == expects or (allow_fuzzy and String.contains?(response, expects))) do
            send parent, {:ok, response}
          else
            expect_packet(socket, expects, parent, allow_fuzzy)
          end
      end
    end
  end

  def seed do
    seed({:user, defaults.login, defaults.password})
  end
  def seed({:user, email, password}) do
    Moongate.Db.UserQueries.create([
      email: email,
      password: password
    ])
  end

  # Send a packet to the server.
  def send_packet(socket, message) do
    length = String.length(String.replace(message, "·", ""))
    packet = "#{length}{#{message}}"
    if defaults.log_packets do
      IO.puts "Client sent packet: #{packet}."
    end
    socket |> Socket.Stream.send! packet
  end

  def transaction(client, params) do
    send_packet(client, params.send)
    expect_packet(client, params.expect, self)
  end
end

# Run tests with ExUnit
Moongate.Tests.Helper.clean
Moongate.Tests.Helper.seed
ExUnit.start()
