require "webrick"

class Hotpages::Site::DevServer
  def initialize(site:)
    @site = site
    @config = site.config
    @port = @config.site.dev_server.port
  end

  def start(gem_development: false)
    @gem_development = gem_development
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
      Hotpages.reload if gem_development?
      site.reload

      # TODO: Error handling for page not found
      page = Hotpages::Page.instance_for(req.path, config:)

      res["Content-Type"] = "text/html"
      res.body = page.render
    end
  end
end
