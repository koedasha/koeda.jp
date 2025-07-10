require "forwardable"

class Hotpages::Page
  extend Forwardable
  include Hotpages::Helpers
  include Expandable, Instantiation, Renderable

  class << self
    def inherited(subclass)
      subclass.layout_path = self.layout_path.dup if self.layout_path
    end

    def layout(layout_path)
      @layout_path = layout_path
    end
    attr_accessor :layout_path
  end

  layout :site # Default layout path, can be overridden by individual pages

  attr_reader :base_path, :id, :config

  def initialize(base_path:, id: nil, config:)
    @base_path = base_path
    @id = id || base_path.split("/").last
    @config = config
  end

  def body = File.read(File.join(config.pages_full_path, "#{base_path}.html.erb"))
end
