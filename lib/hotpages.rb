require "zeitwerk"

module Hotpages
  def self.loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
    loader.inflector.inflect "default_config" => "DEFAULT_CONFIG"
    loader.enable_reloading
  end
  self.loader.setup

  class << self
    def reload
      loader.reload
    end

    def teardown
      loader.unload
      loader.unregister
      site.teardown if site
    end

    def config = @config ||= DEFAULT_CONFIG

    attr_accessor :site
    def setup_site(site_class, &after_setup)
      self.site = site_class.new
      site.setup

      yield(site) if block_given?
    end

    def dev_server
      raise "Site is not set. Please call Hotpages.setup_site first." unless site
      @dev_server ||= Hotpages::DevServer.new(site: site)
    end
  end
end
