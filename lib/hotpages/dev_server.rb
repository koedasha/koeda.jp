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
    @assets_prefix = Hotpages.config.assets.prefix

    self.extend(HotReloading) if hot_reload
  end

  def start(gem_development: false)
    @gem_development = gem_development

    logger.info "Starting development server on port #{port}..."

    Hotpages.eager_load unless gem_development

    setup_routes
    server.start
  end

  def stop
    logger.info "Stopping development server..."
    server.shutdown
  end

  private

  attr_reader :site, :config, :host, :port, :logger, :assets_prefix

  ERROR_PAGE_BODY_STYLE = "font-family:sans-serif; font-size:1.1rem; line-height:1.4;"

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
    if req.path.start_with?(assets_prefix)
      handle_assets_request(req, res)
    else
      handle_page_request(req, res)
    end
  end

  def handle_assets_request(req, res)
    asset_file_path = site.assets.find do |base_path, file|
      file.delete_prefix(base_path.to_s + "/") == req.path.delete_prefix(assets_prefix)
    end&.last

    return res.status = 404 unless asset_file_path

    content = File.read(asset_file_path)

    ext = File.extname(req.path)
    mime_type = WEBrick::HTTPUtils::DefaultMimeTypes[ext.sub(/^\./, "")] || "application/octet-stream"

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

    correction = if e.respond_to?(:corrections)
      "<p><strong>Did you mean?:</strong> <code>#{e.corrections.join("</code>, <code>")}</code></p>"
    else
      ""
    end
    res.status = 500
    res["Content-Type"] = "text/html"
    res.body = <<~HTML
      <body style="#{ERROR_PAGE_BODY_STYLE}">
        <h1>#{e.class.name}</h1>
        <p><strong>Message:</strong> #{e.message}</p>
        #{correction}
        <p><strong>Path:</strong> <code>#{req.path}</code></p>
        <p><strong>Backtrace:</strong><br/>
          #{e.backtrace.map(&method(:render_backtrace_line)).join("\n")}
        </p>
        <small><i>Customize editor links by <code>dev_server.backtrace_link_format</code> config</i></small>
      </body>
    HTML
  end

  def render_backtrace_line(line)
    link_format = Hotpages.config.dev_server.backtrace_link_format
    file_with_line, context = line.split(":in")
    file, line = file_with_line.split(":")

    if link_format
      href = link_format % { file:, line: }
      "<a href=\"#{href}\">#{file}:#{line}</a>:in #{context}<br/>"
    else
      line
    end
  end

  def respond_with_not_found(req, res)
    res.status = 404
    res["Content-Type"] = "text/html"
    res.body = <<~HTML
      <body style="#{ERROR_PAGE_BODY_STYLE}">
        <h1>404 Not Found</h1>
        <p>The requested resource was not found.</p>
        <p><strong>Path:</strong> <code>#{req.path}</code></p>
        <p><strong>Unexpected result?</strong><br/>
          <ol>
            <li>Ensure the path is correct. Files whose names start with `_` are ignored.</li>
            <li>Ensure the ruby file defines page class or template file exists within the `pages` directory structure.</li>
            <li>For expanded pages, ensure a module or class with the `segment_names` class/module method exists for each expanded segment.</li>
            <li>Ensure the `segment_names` class/module method returns an array that includes the requested page or directory name.</li>
            <li>Ensure `segments` key names are not duplicated within nested directory hierarchies. For example, this structure is invalid: `users/__id__/posts/__id__`.</li>
          </ol>
        </p>
      </body>
    HTML
  end
end
