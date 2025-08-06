require "zeitwerk"
require_relative "hotpages/core_ext/string"

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

    attr_accessor :site
    def config = @config ||= DEFAULT_CONFIG.tap { _1.extend(ConfigurationExt) }

    def setup_site(site_class)
      self.site = site_class.new
      site.setup
    end

    def dev_server
      raise "Site is not set. Please call Hotpages.setup_site first." unless site
      @dev_server ||= Hotpages::DevServer.new(site: site)
    end
  end
end
