require "erb"
require "forwardable"

class Hotpages::Page
  extend Forwardable
  include Hotpages::Helpers
  include Expandable, Instantizable

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

  def initialize(base_path:, id: nil, config:)
    @base_path = base_path
    @id = id || base_path.split("/").last
    @config = config
  end

  def body = File.read(File.join(config.pages_full_path, "#{base_path}.html.erb"))

  def render(partial_path = nil, **locals)
    if partial_path # TODO: Refactor erb rendering methods
      render_partial(partial_path, **locals)
    else
      render_layout do
        ERB.new(body, trim_mode: "-").result(binding)
      end
    end
  end

  private

  attr_reader :base_path, :id, :config

  def layout_body
    layout_path = self.class.layout_path

    File.read(File.join(config.layouts_full_path, "#{layout_path}.html.erb"))
  end

  def render_layout
    ERB.new(layout_body, trim_mode: "-").result(binding)
  end

  def render_partial(partial_path, **locals)
    partial_full_path = File.join(config.partials_full_path, "#{partial_path}.html.erb")
    partial_body = File.read(partial_full_path)

    ERB.new(partial_body, trim_mode: "-").result_with_hash(locals.merge(page: self))
  end
end
