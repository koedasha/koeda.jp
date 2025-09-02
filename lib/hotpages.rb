require "zeitwerk"

module Hotpages
  def self.loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
    loader.enable_reloading
  end
  self.loader.setup

  DEFAULT_EXTENSIONS = [
    Extensions::I18n,
    Extensions::Hotwire,
    Extensions::PageMtime
  ]

  class << self
    def eager_load = loader.eager_load

    def reload
      loader.reload.tap do |_result|
        Extension.setup
      end
    rescue Zeitwerk::SetupRequired
      loader.setup
    ensure
      loader.reload.tap do |_result|
        Extension.setup
      end
    end

    def teardown
      loader.unload
      loader.unregister
      site.teardown if site
    end

    # To add/remove extensions, modify this array before calling Extension.setup
    # Extensions order is important, because initialization is performed in the order defined
    # and this affects prepended/included modules' order.
    def extensions = @extensions ||= DEFAULT_EXTENSIONS
    def extensions=(extensions)
      @extensions = extensions
    end

    def config = @config ||= Config.defaults

    attr_accessor :site_class
    def site = @site ||= site_class.instance.tap(&:setup)

    def dev_server = @dev_server ||= DevServer.new(site:)
    def site_generator = @site_generator ||= SiteGenerator.new(site:)
  end
end
