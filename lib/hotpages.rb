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
    def config = @config ||= Configuration.new

    def setup_site(site_class)
      self.site = site_class.instance
      site.setup
    end
  end
end
