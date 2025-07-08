require "webrick"

class Hotpages::DevServer
  def initialize(config: Hotpages.config, site: Hotpages.site)
    @config = config
    @site = site
  end

  def start(gem_development: false)
    @gem_development = gem_development
    puts "Starting development server on port #{@config.dev_server.port}..."
    setup_routes
    server.start
  end

  def stop
    puts "Stopping development server..."
    server.shutdown
  end

  private

  attr_reader :config, :site

  def server
    @server ||= WEBrick::HTTPServer.new(
      Port: config.dev_server.port
    )
  end

  def gem_development? = !!@gem_development

  def setup_routes
    server.mount_proc "/" do |req, res|
      Hotpages.reload if gem_development?
      site.reload

      page = Hotpages::Page.instance_for(req.path, config:)

      res["Content-Type"] = "text/html"
      res.body = page.render
    end
  end
end
