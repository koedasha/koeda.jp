require "digest/sha1"

# Very limited implementation of WebSocket for hot reloading
# Supports only handshake and broadcasting
class Hotpages::DevServer::WebSocket
  module DontCloseAfterNonKeepAliveResponse
    def web_socket_closed? = !!@_ws_closed
    def close_web_socket
      @_ws_closed = true
      close
    end

    def close
      super if @_ws_closed
    end
  end

  def initialize
    @sockets = []
  end

  def handshake_request?(req)
    req.header["sec-websocket-version"]&.first == "13" &&
      req.header["upgrade"]&.first&.downcase == "websocket" &&
      !req.header["sec-websocket-key"]&.first&.empty?
  end

  def handshake(req, res)
    ws_key = req.header["sec-websocket-key"].first
    response_key = Digest::SHA1.base64digest([ws_key, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"].join)

    res.status = 101
    res.upgrade!("websocket")
    res["Sec-WebSocket-Accept"] = response_key

    sockets << req.instance_variable_get(:@socket).tap do
      _1.extend(DontCloseAfterNonKeepAliveResponse)
    end
  end

  def broadcast(message)
    json = JSON.generate(message)
    output = [0b10000001, json.size, json]
    data = output.pack("CCA#{json.size}")

    sockets.each do |socket|
      socket.write(data)
    rescue Errno::EPIPE
      socket.close_web_socket
      sockets.delete(socket)
    end
  end

  def close
    sockets.each(&:close_web_socket)
    sockets.clear
  end

  private

  attr_accessor :sockets
end
