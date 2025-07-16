require "zeitwerk"
require "forwardable"

class Hotpages::Site::Loader
  extend Forwardable

  class Inflector < Zeitwerk::Inflector
    def camelize(basename, abspath)
      if basename =~ Hotpages::Page::Expandable::EXPANDABLE_BASENAME_REGEXP
        super($1, abspath)
      else
        super
      end
    end
  end

  def initialize(config:)
    @loader = Zeitwerk::Loader.new.tap do |loader|
      loader.inflector = Inflector.new
      loader.push_dir(config.site.root)
      loader.collapse(config.site.models_full_path)
      loader.collapse(config.site.helpers_full_path)
      loader.ignore(config.site.assets_full_path)
      loader.ignore(config.site.layouts_full_path)
      loader.ignore(config.site.partials_full_path)
      loader.enable_reloading
    end
  end

  delegate [:setup, :reload, :unload, :unregister] => :loader

  private

  attr_reader :loader
end
