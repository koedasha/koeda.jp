require "zeitwerk"
require "forwardable"

class Hotpages::Site::Loader
  extend Forwardable

  def initialize(config:)
    @loader = Zeitwerk::Loader.new.tap do |loader|
      loader.push_dir(config.site.root)
      loader.collapse(config.models_full_path)
      loader.collapse(config.helpers_full_path)
      loader.ignore(config.assets_full_path)
      loader.ignore(config.layouts_full_path)
      loader.ignore(config.partials_full_path)
      loader.enable_reloading
    end
  end

  delegate [:setup, :reload, :unload, :unregister] => :loader

  private

  attr_reader :loader
end
