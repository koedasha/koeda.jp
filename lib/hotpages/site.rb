require "forwardable"
require "pathname"

class Hotpages::Site
  extend Forwardable
  using Hotpages::Refinements::String

  class << self
    def inherited(base)
      super

      Hotpages::Extension.setup!

      base_class_location = Object.const_source_location(base.name).first
      config.site.root = Pathname.new(base_class_location).join("../site")
    end

    def config = @config ||= Hotpages.config
  end

  attr_reader :config

  def initialize
    @config = self.class.config
    @loader = Loader.new(site: self)
    @generator = Generator.new(site: self)
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
  end

  delegate %i[ generate generating? ] => :generator

  attr_accessor :phantom_page_base_class

  def pages_namespace_module(ns_name = config.site.pages_namespace)
     Object.const_defined?(ns_name) ? Object.const_get(ns_name)
                                    : Object.const_set(ns_name, Module.new)
  end

  def assets_paths = [ assets_path ]
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

    delegate %i[
      root dist_dir models_dir helpers_dir layouts_dir assets_dir pages_dir shared_dir
    ] => :site_config

    def dist_path = root.join(dist_dir)
    def models_path = root.join(models_dir)
    def helpers_path = root.join(helpers_dir)
    def layouts_path = root.join(layouts_dir)
    def assets_path = root.join(assets_dir)
    def pages_path = root.join(pages_dir)
    def shared_path = root.join(shared_dir)

    private

    def site_config = config.site
  end
  include Paths

  private

  attr_accessor :loader, :generator
end
