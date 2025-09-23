require "singleton"
require "forwardable"
require "pathname"
require "zeitwerk"

class Hotpages::Site
  include Singleton, Hotpages::Support::Hooks
  extend Forwardable
  using Hotpages::Support::StringInflections

  class << self
    def inherited(subclass)
      Hotpages::Extension.setup(
        extensions: Hotpages.extensions,
        config: Hotpages.config
      )

      super

      Hotpages.site_class = subclass

      base_class_location = Object.const_source_location(subclass.name).first
      config.site.root = Pathname.new(base_class_location).join("../site")
    end

    def config = @config ||= Hotpages.config
  end

  attr_reader :config
  define_hook :initialize, only: :after

  def initialize
    run_hooks :initialize do
      @config = self.class.config
      @loader = Zeitwerk::Loader.new.tap do |loader|
        loader.push_dir(self.models_path)
        loader.push_dir(self.helpers_path)
        loader.push_dir(self.shared_path)
        loader.collapse(self.root.join("*/concerns"))
        loader.enable_reloading
      end
    end
  end

  def setup
    loader.setup
  end

  def teardown
    loader.unload
    loader.unregister
  end

  def reload
    loader.reload
  rescue Zeitwerk::SetupRequired
    loader.setup
  ensure
    loader.reload
  end

  def cache = @cache ||= Hotpages::Support::Cache::Store.new

  def page_base_class(class_name: config.site.page_base_class_name)
    class_name.constantize
  end

  def assets_paths = @assets_paths ||= [ assets_path ]
  def assets(filter_ext = nil)
    Enumerator.new do |yielder|
      assets_paths.each do |path|
        Dir.glob(File.join(path, "**", "*#{filter_ext}")).select do |file|
          next unless File.file?(file)
          yielder << [ path, file ]
        end
      end
    end
  end

  def helper_constants
    Dir.glob(helpers_path.join("**/*_helper.rb")).map do |file|
      file_name = file.sub(helpers_path.to_s + "/", "").sub(/\.rb\z/, "")
      file_name.classify.constantize
    end
  end

  module Paths
    extend Forwardable

    delegate %i[ root directory ] => :site_config

    def dist_path = root.join(site_config.dist_path)

    def pages_path = root.join(directory.pages)
    def models_path = root.join(directory.models)
    def layouts_path = root.join(directory.layouts)
    def helpers_path = root.join(directory.helpers)
    def assets_path = root.join(directory.assets)
    def shared_path = root.join(directory.shared)

    private

    def site_config = config.site
  end
  include Paths

  private

  attr_accessor :loader
end
