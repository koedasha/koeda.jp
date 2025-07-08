require "zeitwerk"

module Hotpages
  class << self
    def loader = @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
      loader.enable_reloading
    end

    def reload = loader.reload
  end
end

Hotpages.loader.setup
