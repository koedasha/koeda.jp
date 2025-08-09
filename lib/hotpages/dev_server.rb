require "webrick"

class Hotpages::DevServer
  def initialize(
    site:,
    host: "localhost",
    port: Hotpages.config.dev_server.port,
    hot_reload: Hotpages.config.dev_server.hot_reloading_enabled
  )
    @site = site
    @host = host
    @port = port
    @logger = WEBrick::Log.new()

    self.extend(HotReloading) if hot_reload
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

  attr_reader :site, :config, :host, :port, :logger

  def server
    @server ||= WEBrick::HTTPServer.new(
      Port: port
    )
  end

  def gem_development? = !!@gem_development

  def page_finder
    @page_finder ||= Hotpages::Page::Finder.new(site)
  end

  def setup_routes
    server.mount_proc "/" do |req, res|
      res["Cache-Control"] = "no-store"
      handle_request(req, res)
    end
  end

  def handle_request(req, res)
    if req.path.start_with?("/#{site.assets_dir}/")
      handle_assets_request(req, res)
    else
      handle_page_request(req, res)
    end
  end

  def handle_assets_request(req, res)
    ext = File.extname(req.path)
    asset_file_path = site.root_path.join(req.path.delete_prefix("/"))
    content = File.read(asset_file_path)
    mime_type = WEBrick::HTTPUtils::DefaultMimeTypes[ext.sub(/^\./, '')] || "application/octet-stream"
    res["Content-Type"] = mime_type
    res.body = content
  rescue Errno::ENOENT => e
    logger.error(e)
    res.status = 404
  end

  def page_content(page) = page.render

  def handle_page_request(req, res)
    if gem_development?
      logger.info "Gem development mode enabled. Reloading Hotpages: #{Hotpages.reload}"
    end
    site.reload

    page = page_finder.find(req.path)

    return respond_with_not_found(req, res) unless page

    res["Content-Type"] = "text/html"
    res.body = page_content(page)
  rescue Exception => e
    logger.error(e)

    res.status = 500
    res["Content-Type"] = "text/html"
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
    res["Content-Type"] = "text/html"
    res.body = <<~HTML
      <body style="font-family:sans-serif; font-size:1.2rem; line-height:1.4;">
        <h1>404 Not Found</h1>
        <p>The requested resource was not found.</p>
        <p><strong>Path:</strong> #{req.path}</p>
        <p><strong>Unexpected result?</strong></p>
        <ol style="">
          <li>Make sure the path is correct.</li>
          <li>Ensure the page class or template file exists under the `pages` directory structure.</li>
          <li>For expanded pages, ensure module/class with `segment_names` class/module method exists for each expanded segment.</li>
          <li>Ensure `segment_names` class/module method returns an array that includes the requested page/directory name.</li>
          <li>Ensure `segments` key names are not duplicated within nested directory hierarchies. e.g. This is invalid structure: `users/__id__/posts/__id__`</li>
        </ol>
      </body>
    HTML
  end
end
