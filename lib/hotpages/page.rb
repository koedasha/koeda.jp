require "erb"
require "forwardable"

class Hotpages::Page
  extend Forwardable

  class << self
    def inherited(subclass)
      subclass.layout_path = self.layout_path.dup if self.layout_path
    end

    # TODO: Handle case where page_class is not defined
    def instance_for(page_path, config:)
      page_path = "#{page_path}index" if page_path.end_with?("/")
      page_path = page_path.sub(%r{^/}, '') # Remove leading slash if present
      namespace = config.pages_namespace_module
      const_name = page_path.split('/').map(&:capitalize).join('::')
      page_class = namespace.const_get(const_name)
      page_class.new(base_path: page_path, config:)
    end

    def layout(layout_path)
      @layout_path = layout_path
    end
    attr_accessor :layout_path
  end

  layout :site # Default layout path, can be overridden by individual pages

  def initialize(base_path: nil, config: nil)
    @base_path = base_path
    @config = config
  end

  def body = File.read(File.join(config.pages_full_path, "#{base_path}.html.erb"))

  def render
    render_layout do
      ERB.new(body, trim_mode: "-").result(binding)
    end
  end

  private

  attr_reader :base_path, :config

  def layout_body
    layout_path = self.class.layout_path

    File.read(File.join(config.layouts_full_path, "#{layout_path}.html.erb"))
  end

  def render_layout
    ERB.new(layout_body, trim_mode: "-").result(binding)
  end
end
