require "listen"

# TODO: E2E Testing
module Hotpages::Extensions::HotReloading
  extend Hotpages::Extension

  prepending to: "Hotpages::DevServer"

  HOT_RELOADING_JS = "_hot_reloading.js"

  def start(gem_development: false)
    logger.info "Hot reloading enabled"

    @web_socket = WebSocket.new
    @web_socket_url = "ws://#{host}:#{port}"
    # Set wait_for_delay to 0.2 seconds for more stable hot reloading
    @file_listener = Listen.to(site.root_path, wait_for_delay: 0.2) do |modified, added, removed|
      (modified + added + removed).each do |changed_file|
        handle_file_change(changed_file)
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

  attr_reader :web_socket, :web_socket_url, :file_listener

  def page_content(page)
    content = super

    hot_reload_scripts = <<~HTML
      <script>window._HOTPAGES_HOT_RELOADING_WS_URL="#{web_socket_url}"</script>
      <script src=\"/#{HOT_RELOADING_JS}\" type=\"module\"></script>
    HTML
    content.sub(/<\/head>/, "#{hot_reload_scripts}\n</head>")
  end

  def handle_request(req, res)
    if req.path == "/#{HOT_RELOADING_JS}"
      res["Content-Type"] = "application/javascript"
      res.body = File.read(File.join(__dir__, "hot_reloading", HOT_RELOADING_JS))
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
        web_socket.broadcast(action: "reload:js", path: file_path_to_notify)
      end
    else
      web_socket.broadcast(action: "reload:html")
    end
  end
end
