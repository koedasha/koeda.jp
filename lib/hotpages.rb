require "zeitwerk"
require_relative "./hotpages/string_ext"

module Hotpages
  def self.loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
    loader.inflector.inflect "default_config" => "DEFAULT_CONFIG"
    loader.enable_reloading
  end
  loader.setup

  class << self
    def reload
      loader.reload
    rescue Zeitwerk::SetupRequired # TODO: Correct to handle like this?
      loader.setup
    ensure
      loader.reload
    end

    def teardown
      loader.unload
      loader.unregister
    end

    attr_accessor :site
    def config = @config ||= DEFAULT_CONFIG

    def setup_site(site_class)
      self.site = site_class.instance
      site.setup
    end
  end
end
