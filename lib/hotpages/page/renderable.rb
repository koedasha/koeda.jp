require "tilt"
require "erubi"
require "erubi/capture_block"

module Hotpages::Page::Renderable
  def render
    page_content = new_tilt("erb") { body }.render(rendering_context)

    render_layout do |content_name = nil|
      if content_name
        rendering_context.contents[content_name.to_sym]
      else
        page_content
      end
    end
  end

  private

  class RenderingContext
    attr_reader :contents

    def initialize(page)
      @page = page
      @contents = {}
    end

    private

    attr_reader :page

    # Partial rendering
    def render(partial_path, **locals)
      partial_full_path = File.join(page.config.partials_full_path, "#{partial_path}.html.erb")

      new_tilt(partial_full_path).render(self, locals)
    end

    # Method delegation
    def respond_to_missing?(method_name, include_private = false)
      page.respond_to?(method_name, true) || super
    end
    def method_missing(method_name, *args, &block)
      if page.respond_to?(method_name, true)
        page.send(method_name, *args, &block)
      else
        super
      end
    end

    # Helper methods for capturing content
    def capture(&block) = @buf.capture(&block)
    def content_for(name, content = nil, &block)
      return @contents[name.to_sym] if !content && !block_given?

      content ||= block.call if block_given?
      @contents[name.to_sym] = content
    end
    def content_for?(name)
      @contents.key?(name.to_sym)
    end
  end
  def rendering_context
    # We should use same context for all render calls
    @rendering_context ||= RenderingContext.new(self).tap do |context|
      self.class.helpers&.each do |helper_module|
        context.extend(helper_module)
      end
    end
  end

  def new_tilt(template_path, &block)
    Tilt.new(template_path, engine_class: Erubi::CaptureBlockEngine, bufvar: "@buf", &block)
  end

  def layout_template
    @layout_template ||=
      new_tilt(File.join(config.layouts_full_path, "#{self.class.layout_path}.html.erb"))
  end
  def render_layout(&block)
    layout_template.render(rendering_context, &block)
  end
end
