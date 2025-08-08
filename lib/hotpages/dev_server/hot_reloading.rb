require "listen"

# TODO: JS support / E2E Testing
module Hotpages::DevServer::HotReloading
  HOT_RELOADING_JS = "_hot_reloading.js"

  def start(gem_development: false)
    logger.info "Hot reloading enabled"

    @web_socket = Hotpages::DevServer::WebSocket.new
    @file_listener = Listen.to(site.root_path) do |modified_files, _added, _removed|
      modified_files.each do |modified|
        handle_file_change(modified)
      end
    end
    @file_listener.start

    super
  end

  def stop
    web_socket.close
    super
  end

  private

  attr_reader :web_socket, :file_listener

  def page_content(page)
    content = super
    content.sub(/<\/head>/, "  <script src=\"/#{HOT_RELOADING_JS}\" type=\"module\"></script>\n</head>")
  end

  def handle_request(req, res)
    if req.path == "/#{HOT_RELOADING_JS}"
      res["Content-Type"] = "application/javascript"
      res.body = File.read(File.join(__dir__, HOT_RELOADING_JS))
    elsif web_socket.handshake_request?(req)
      web_socket.handshake(req, res)
    else
      super(req, res)
    end
  end

  def handle_file_change(file_path)
    file_path_to_notify = file_path.sub(site.root, "")

    if file_path.start_with?(site.assets_path.to_s)
      case file_path
      when /\.css$/
        web_socket.broadcast(action: "reload:css", path: file_path_to_notify)
      when /\.js$/
        web_socket.broadcast(action: "reload:js")
      end
    else
      web_socket.broadcast(action: "reload:html")
    end
  end
end
