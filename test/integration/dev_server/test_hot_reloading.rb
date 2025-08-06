require "test_helper"
require "net/http"

class TestHotReloading < Minitest::Test
  @@setup_done = false
  def setup
    return if @@setup_done

    @@port = 12346
    @@server = Hotpages::DevServer.new(site: Hotpages.site, port: @@port, hot_reload: true)
    @@server_thread = Thread.new { @@server.start }
    @@setup_done = true

    sleep 0.1
  end

  Minitest.after_run do
    if defined?(@@server_thread)
      @@server.stop
      @@server_thread.join
      @@server = nil
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
    FileUtils.touch(File.join(Hotpages.config.site.pages_absolute_path, "index.html.erb"))
    response = client_socket.readpartial(1024)
    assert_match %r{{"action":"reload:html"}}, response

    # CSS
    FileUtils.touch(File.join(Hotpages.config.site.assets_absolute_path, "base.css"))
    response = client_socket.readpartial(1024)
    assert_match %r{{"action":"reload:css"}}, response

    # JS
    FileUtils.touch(File.join(Hotpages.config.site.assets_absolute_path, "site.js"))
    response = client_socket.readpartial(1024)
    assert_match %r{{"action":"reload:js"}}, response
  end
end
