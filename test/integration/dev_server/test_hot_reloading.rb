require "test_helper"
require "net/http"

class TestHotReloading < Minitest::Test
  @@setup_done = false
  def setup
    return if @@setup_done

    @@port = 12346
    @@server_pid = fork do
      Hotpages.extensions << Hotpages::Extensions::HotReloading
      Hotpages.reload
      Hotpages.site.reload

      server = Hotpages::DevServer.new(site: Hotpages.site, port: @@port)
      trap("TERM") { server.stop }
      server.start
    end
    @@setup_done = true

    sleep 0.1
  end

  Minitest.after_run do
    if defined?(@@server_pid)
      Process.kill("TERM", @@server_pid)
      sleep 0.1
    end
  end

  def test_sse_broadcasting
    client_socket = TCPSocket.new("localhost", @@port)

    # Initial request
    client_socket.write <<~REQ
      GET #{Hotpages::Extensions::HotReloading::FILE_CHANGES_PATH} HTTP/1.1\r
      Host: localhost:#{@@port}\r
      Accept: text/event-stream\r
      Cache-Control: no-cache\r
      Connection: keep-alive\r
      \r
    REQ
    response = client_socket.readpartial(1024)
    expected_response = [
      "HTTP/1.1 200 OK",
      "Content-Type: text/event-stream",
      "Transfer-Encoding: chunked",
      "Connection: Keep-Alive"
    ]
    assert_equal expected_response, response.split("\r\n").reject { it.start_with?("Server: ", "Date: ") }

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
    assert_match %r{{"action":"reload:js","path":"/assets/site.js"}}, response
  end
end
