require "zeitwerk"

module Hotpages
  class << self
    def loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
      loader.enable_reloading
    end
    def reload
      loader.reload
    rescue Zeitwerk::SetupRequired # TODO: Correct to handle like this?
      loader.setup
    ensure
      loader.reload
    end

    def setup
      loader.setup
    end

    def teardown
      loader.unload
      loader.unregister
    end

    attr_accessor :site
    def config = @config ||= Configuration.new(
      root: nil,
      site: Configuration.new(
        root: "site",
        models_path:"models",
        layouts_path: "layouts",
        assets_path: "assets",
        importmaps: {
          "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@latest/dist/turbo.es2017-esm.min.js",
          "@hotwired/stimulus": "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js",
        },
        pages_path: "pages",
        pages_namespace: "Pages",
        dist_path: "dist",
        dev_server: Configuration.new(
          port: 8080
        )
      )
    )

    def setup_site(site_class)
      self.site = site_class.instance
      site.setup
    end
  end
end
