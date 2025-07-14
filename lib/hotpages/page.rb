require "forwardable"

class Hotpages::Page
  extend Forwardable
  include Expandable, Instantiation, Renderable, Findable
  include Hotpages::Helpers

  class << self
    # Class wide configuration refers to Hotpages.config
    def config = @config ||= Hotpages.config

    def inherited(subclass)
      subclass.layout_path = self.layout_path.dup if self.layout_path
      subclass.helpers = self.helpers.dup if self.helpers
    end

    def layout(layout_path)
      @layout_path = layout_path
    end
    attr_accessor :layout_path

    # Helper methods will be merged into the rendering context
    def helper(*helper_modules)
      @helpers ||= []
      @helpers.concat(helper_modules)
    end
    attr_accessor :helpers
  end

  layout :site # Default layout path, can be overridden by individual pages

  attr_reader :base_path, :name, :config

  def initialize(base_path:, name: nil)
    @base_path = base_path
    @name = name || base_path.split("/").last
    @config = self.class.config
  end

  def body = File.read(File.join(config.site.pages_full_path, "#{base_path}.html.erb"))
end
