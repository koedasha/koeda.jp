require "zeitwerk"
require "tilt" # For registering templates in setup_site methods' after_setup block

module Hotpages
  def self.loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
    loader.enable_reloading
  end
  self.loader.setup

  DEFAULT_EXTENSIONS = [
    Extensions::I18n,
    Extensions::Hotwire,
    Extensions::PageMtime,
    Extensions::HotReloading
  ]

  class << self
    def eager_load = loader.eager_load

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

    def extensions = @extensions ||= DEFAULT_EXTENSIONS

    def config = @config ||= Config.defaults

    attr_accessor :site
    def setup_site(site_class, &after_setup)
      self.site = site_class.new
      site.setup

      yield(site) if block_given?

      site
    end

    def dev_server
      raise "Site is not set. Please call Hotpages.setup_site first." unless site
      @dev_server ||= Hotpages::DevServer.new(site: site)
    end
  end
end
