require "zeitwerk"
require "tilt" # For registering templates in setup_site methods' after_setup block

module Hotpages
  def self.loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
    loader.enable_reloading
  end
  self.loader.setup

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

    def extensions = @extensions ||= [
      Extensions::I18n, Extensions::Hotwire
    ]
    def remove_extension(extension) = extensions.delete(extension)
    def extension_helpers = @extension_helpers ||= []

    def config = @config ||= Config.defaults

    def init = extensions.each { _1.setup!(self) }

    attr_accessor :site
    def setup_site(site_class, &after_setup)
      self.site = site_class.new
      site.setup

      yield(site) if block_given?

      site
    end

    # TODO: move assets related methods to Site
    # def assets_path = File.join(__dir__, "hotpages/assets")

    def dev_server
      raise "Site is not set. Please call Hotpages.setup_site first." unless site
      @dev_server ||= Hotpages::DevServer.new(site: site)
    end
  end
end
