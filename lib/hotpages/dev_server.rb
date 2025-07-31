require "webrick"

class Hotpages::DevServer
  def initialize(site:)
    @site = site
    @config = site.config
    @port = @config.dev_server.port
    @logger = WEBrick::Log.new()
  end

  def start(gem_development: false)
    @gem_development = gem_development
    # TDOO: eager_load Hotpages libs when gem development is off
    logger.info "Starting development server on port #{port}..."
    setup_routes
    server.start
  end

  def stop
    logger.info "Stopping development server..."
    server.shutdown
  end

  private

  attr_reader :site, :config, :port, :logger

  def server
    @server ||= WEBrick::HTTPServer.new(
      Port: port
    )
  end

  def gem_development? = !!@gem_development

  def setup_routes
    server.mount_proc "/" do |req, res|
      if req.path.start_with?("/#{config.site.assets_path}/")
        handle_assets_request(req, res)
      else
        handle_page_request(req, res)
      end

      res["Cache-Control"] = "no-store"
    end
  end

  private

  def handle_assets_request(req, res)
    ext = File.extname(req.path)
    asset_file_path = File.join(config.site.root, req.path)
    content = File.read(asset_file_path)
    mime_type = WEBrick::HTTPUtils::DefaultMimeTypes[ext.sub(/^\./, '')] || "application/octet-stream"
    res["Content-Type"] = mime_type
    res.body = content
  rescue Errno::ENOENT => e
    logger.error(e)
    respond_with_not_found(req, res)
  end

  def handle_page_request(req, res)
    if gem_development?
      logger.info "Gem development mode enabled. Reloading Hotpages: #{Hotpages.reload}"
    end
    site.reload

    page = Hotpages::Page.find_by_path(req.path)

    return respond_with_not_found(req, res) unless page

    res["Content-Type"] = "text/html"
    res.body = page.render
  rescue Exception => e
    logger.error(e)

    res.status = 500
    res.body = <<~HTML
      <body style="font-family:sans-serif; font-size:14px;">
        <h1>#{e.class.name}</h1>
        <p><strong>Message:</strong> #{e.message}</p>
        <p><strong>Path:</strong> #{req.path}</p>
        <p><strong>Backtrace:</strong></p>
        <pre>#{e.backtrace.join("\n")}</pre>
      </body>
    HTML
  end

  def respond_with_not_found(req, res)
    res.status = 404
    res.body = <<~HTML
      <body style="font-family:sans-serif; font-size:14px;">
        <h1>404 Not Found</h1>
        <p>The requested resource was not found.</p>
        <p><strong>Path:</strong> #{req.path}</p>
      </body>
    HTML
    res["Content-Type"] = "text/html"
  end
end
