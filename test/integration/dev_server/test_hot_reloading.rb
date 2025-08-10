require "test_helper"
require "net/http"

class TestHotReloading < Minitest::Test
  @@setup_done = false
  def setup
    return if @@setup_done

    @@port = 12346
    @@server_pid = fork do
      server = Hotpages::DevServer.new(site: Hotpages.site, port: @@port, hot_reload: true)
      trap("INT") { server.stop }
      server.start
    end
    @@setup_done = true

    sleep 0.1
  end

  Minitest.after_run do
    if defined?(@@server_pid)
      Process.kill("INT", @@server_pid)
      sleep 0.1
    end
  end

  def test_websocket_broadcasting
    client_socket = TCPSocket.new("localhost", @@port)
    # Handshake
    ws_key = "\u0005\x94\xDE\u0015\xE5ߝ\xF3y\xAFhb5j\xE5\xAC"
    client_socket.write(
      "GET / HTTP/1.1\r\n" \
      "Host: localhost:#{@@port}\r\n" \
      "Upgrade: websocket\r\n" \
      "Connection: Upgrade\r\n" \
      "Sec-WebSocket-Key: #{ws_key}\r\n" \
      "Sec-WebSocket-Version: 13\r\n" \
      "\r\n"
    )
    response = client_socket.readpartial(1024)
    expected_response = [
      "HTTP/1.1 101 Switching Protocols",
      "Cache-Control: no-store",
      "Sec-Websocket-Accept: URl35r+QDG0yinZSZgNLSWrT+MA=",
      "Connection: upgrade",
      "Upgrade: websocket"
    ]
    assert_equal expected_response, response.split("\r\n").reject { _1.start_with?("Server: ", "Date: ") }

    # Notify file changes
    # HTML
    FileUtils.touch Hotpages.site.pages_path.join("index.html.erb")
    response = client_socket.readpartial(1024)
    assert_match %r{{"action":"reload:html"}}, response

    # CSS
    FileUtils.touch Hotpages.site.assets_path.join("base.css")
    response = client_socket.readpartial(1024)
    assert_match %r{{"action":"reload:css","path":"/assets/base.css"}}, response

    # JS
    FileUtils.touch Hotpages.site.assets_path.join("site.js")
    response = client_socket.readpartial(1024)
    assert_match %r{{"action":"reload:js"}}, response
  end
end
