require "forwardable"

class Hotpages::Page
  extend Forwardable
  include Expandable, Instantiation, Renderable, Findable

  class << self
    def inherited(subclass)
      subclass.layout_path = self.layout_path.dup if self.layout_path
      subclass.helpers = self.helpers.dup if self.helpers
    end

    def layout(layout_path)
      @layout_path = layout_path
    end
    attr_accessor :layout_path

    def helper(*helper_modules)
      @helpers ||= []
      @helpers.concat(helper_modules)
    end
    attr_accessor :helpers
  end

  layout :site # Default layout path, can be overridden by individual pages
  helper Hotpages::Helpers

  attr_reader :base_path, :id, :config

  def initialize(base_path:, id: nil, config:)
    @base_path = base_path
    @id = id || base_path.split("/").last
    @config = config
  end

  def body = File.read(File.join(config.pages_full_path, "#{base_path}.html.erb"))
end
