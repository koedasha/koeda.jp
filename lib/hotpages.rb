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

    # To add/remove extensions, modify this array before calling Extension.setup!
    def extensions = @extensions ||= DEFAULT_EXTENSIONS

    def config = @config ||= Config.defaults

    attr_accessor :site_class
    def site = @site ||= Site.instance.tap(&:setup)

    def dev_server
      @dev_server ||= Hotpages::DevServer.new(site:)
    end
  end
end
