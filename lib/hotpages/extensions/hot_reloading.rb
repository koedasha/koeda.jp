require "listen"
require "json"

# TODO: E2E Testing
module Hotpages::Extensions::HotReloading
  extend Hotpages::Extension

  prepending to: "Hotpages::DevServer"

  FILE_CHANGES_PATH = "/_file_changes"
  HOT_RELOADING_JS_PATH = "/_hot_reloading.js"

  def start(gem_development: false)
    logger.info "Hot reloading enabled"

    @file_changes_streams = []
    # Set wait_for_delay to 0.2 seconds for more stable hot reloading
    @file_listener = Listen.to(site.root, wait_for_delay: 0.2) do |modified, added, removed|
      (modified + added + removed).each do |changed_file|
        handle_file_change(changed_file)
      end
    end
    @file_listener.start

    super
  end

  private

  attr_reader :file_changes_streams, :file_listener

  class FileChangesStream < StringIO
    def readpartial(len, buf = "")
      partial = nil

      # TODO: Cannot stop serving with INT
      while !partial
        rewind
        partial = read_nonblock(len, buf, exception: false)
        sleep 0.1
      end

      self.string.clear

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

      FileChangesStream.new.tap do |stream|
        file_changes_streams << stream
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
    file_changes_streams.each do
      it.write("data: #{JSON.generate(payload)}\n\n")
    rescue IOError
      file_changes_streams.delete(it)
    end
  end
end
