require "zeitwerk"
require "forwardable"

class Hotpages::Site::Loader
  extend Forwardable

  def initialize(config:)
    @loader = Zeitwerk::Loader.new.tap do |loader|
      loader.push_dir(config.site.pages_absolute_path, namespace: config.site.pages_namespace_module)
      loader.push_dir(config.site.models_absolute_path)
      loader.push_dir(config.site.helpers_absolute_path)
      loader.push_dir(config.site.shared_absolute_path)
      loader.enable_reloading
    end
  end

  delegate %i[ setup reload unload unregister ] => :loader

  private

  attr_reader :loader
end
