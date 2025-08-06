require "zeitwerk"
require "forwardable"

class Hotpages::Site::Loader
  extend Forwardable

  def initialize(site:)
    @loader = Zeitwerk::Loader.new.tap do |loader|
    loader.push_dir(site.pages_path, namespace: site.pages_namespace_module)
      loader.push_dir(site.models_path)
      loader.push_dir(site.helpers_path)
      loader.push_dir(site.shared_path)
      loader.collapse(site.root_path.join("*/concerns"))
      loader.enable_reloading
    end
  end

  delegate %i[ setup reload unload unregister ] => :loader

  private

  attr_reader :loader
end
