require "listen"
require "json"

# TODO: E2E Testing
module Hotpages::Extensions::DevServer::HotReloading
  extend Hotpages::Extension

  spec do
    it.prepend to: Hotpages::DevServer
  end

  FILE_CHANGES_PATH = "/_file_changes"
  HOT_RELOADING_JS_PATH = "/_hot_reloading.js"

  def start(gem_development: false)
    logger.info "Hot reloading enabled"

    @file_change_streams = []
    # Set wait_for_delay to 0.2 seconds for more stable hot reloading
    @file_listener = Listen.to(site.root, wait_for_delay: 0.2) do |modified, added, removed|
      (modified + added + removed).each do |changed_file|
        handle_file_change(changed_file)
      end
    end
    @file_listener.start

    super
  end

  def stop
    super
    file_change_streams.each { it.close }
    file_change_streams.clear
  end

  private

  attr_reader :file_change_streams, :file_listener

  # By setting res.chunked = true and assigning object responds to readpartial to res.body,
  # WEBrick::HTTPResponse will call readpartial and set its results as the chunked response.
  # However, EOFError (with normal readpartial) or Errno::EPIPE (when an empty string is set to the buffer) can occur,
  # making it unable to maintain the connection.
  # By assigning an instance of this class to res.body, the SSE connection can be maintained.
  # This behavior was confirmed with WEBrick v1.9.1
  class FileChangeStream < StringIO
    def readpartial(len, buf = +"")
      partial = nil

      while !closed? && !partial
        rewind
        partial = read_nonblock(len, buf, exception: false)
        sleep 0.1
      end

      string.clear

      partial
    end
  end

  def page_content(page)
    content = super

    hot_reload_scripts = <<~HTML
      <script>window._HOTPAGES_FILE_CHANGES_PATH="#{FILE_CHANGES_PATH}"</script>
      <script src=\"#{HOT_RELOADING_JS_PATH}\" type=\"module\"></script>
    HTML
    content.sub(/<\/head>/, "#{hot_reload_scripts}\n</head>")
  end

  def setup_routes
    super

    server.mount_proc HOT_RELOADING_JS_PATH do |req, res|
      res["Cache-Control"] = "no-store"
      res["Content-Type"] = "application/javascript"
      res.body = File.read(File.join(__dir__, "hot_reloading", HOT_RELOADING_JS_PATH))
    end

    server.mount_proc FILE_CHANGES_PATH do |req, res|
      res["Content-Type"] = "text/event-stream"
      res.chunked = true
      res.keep_alive = true

      FileChangeStream.new.tap do |stream|
        file_change_streams << stream
        res.body = stream
      end
    end
  end

  def handle_file_change(file_path)
    file_path_to_notify = file_path.sub(site.root.to_s, "")

    if file_path.start_with?(site.assets_path.to_s)
      case file_path
      when /\.css$/
        broadcast_file_change(action: "reload:css", path: file_path_to_notify)
      when /\.js$/
        broadcast_file_change(action: "reload:js", path: file_path_to_notify)
      end
    else
      broadcast_file_change(action: "reload:html")
    end
  end

  def broadcast_file_change(payload)
    file_change_streams.each do |stream|
      stream.write("data: #{JSON.generate(payload)}\n\n")
    rescue IOError
      stream.close
      file_change_streams.delete(stream)
    end
  end
end
