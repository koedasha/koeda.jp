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

    attr_accessor :site
    def config = @config ||= Configuration.new.tap { _1.extend(ConfigurationExt) }
  end
end

Hotpages.loader.setup
