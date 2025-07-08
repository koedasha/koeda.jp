require "zeitwerk"
require "forwardable"

class Hotpages::SiteLoader
  extend Forwardable

  def initialize(config: Hotpages.config)
    @loader = Zeitwerk::Loader.new.tap do |loader|
      loader.push_dir(config.models_full_path)
      loader.push_dir(config.pages_full_path, namespace: config.pages_namespace_module)
      loader.enable_reloading
    end
  end

  delegate [:setup, :reload] => :loader

  private

  attr_reader :loader
end
