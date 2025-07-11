require "webrick"

class Hotpages::Site::DevServer
  def initialize(site:)
    @site = site
    @config = site.config
    @port = @config.site.dev_server.port
  end

  def start(gem_development: false)
    @gem_development = gem_development
    # TDOO: eager_load Hotpages libs when gem development is off
    puts "Starting development server on port #{port}..."
    setup_routes
    server.start
  end

  def stop
    puts "Stopping development server..."
    server.shutdown
  end

  private

  attr_reader :site, :config, :port

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
    asset_file_path = File.join(config.site_full_path, req.path)
    content = File.read(asset_file_path)
    mime_type = WEBrick::HTTPUtils::DefaultMimeTypes[ext.sub(/^\./, '')] || "application/octet-stream"
    res["Content-Type"] = mime_type
    res.body = content
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
    respond_with_not_found(res)
  end

  def handle_page_request(req, res)
    if gem_development?
      puts "Gem development mode enabled. Reloading Hotpages: #{Hotpages.reload}"
    end
    site.reload

    page = Hotpages::Page.find_by_path(req.path)

    return respond_with_not_found(res) unless page

    res["Content-Type"] = "text/html"
    res.body = page.render
  end

  def respond_with_not_found(res)
    res.status = 404
    res.body = "<h1>404 Not Found</h1><p>The requested page was not found.</p>"
    res["Content-Type"] = "text/html"
  end
end
