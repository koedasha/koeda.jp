require "zeitwerk"
require "tilt" # For registering templates in setup_site methods' after_setup block

module Hotpages
  def self.loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
    loader.enable_reloading
  end
  self.loader.setup

  EXTENSIONS = [
    Extensions::Localization
  ]
  EXTENSIONS.each { _1.setup!(self.loader) }

  class << self
    def reload
      loader.reload
    rescue Zeitwerk::SetupRequired
      loader.setup
    ensure
      loader.reload
    end

    def teardown
      loader.unload
      loader.unregister
      site.teardown if site
    end

    def config = @config ||= Config.defaults

    attr_accessor :site
    def setup_site(site_class, &after_setup)
      self.site = site_class.new
      site.setup

      yield(site) if block_given?

      site
    end

    def assets_path = File.join(__dir__, "hotpages/assets")
    def assets_paths = [ assets_path, site.assets_path ].compact
    def assets(filter_ext = nil)
      Enumerator.new do |yielder|
        assets_paths.each do |path|
          Dir.glob(File.join(path, "**", "*#{filter_ext}")).select do |file|
            next unless File.file?(file)
            yielder << [ path, file ]
          end
        end
      end
    end

    def dev_server
      raise "Site is not set. Please call Hotpages.setup_site first." unless site
      @dev_server ||= Hotpages::DevServer.new(site: site)
    end
  end
end
