require "erubi"
require "tilt"

module Hotpages::Page::Renderable
  def render
    render_layout do
      Tilt.new("erb") { body }.render(render_context)
    end
  end

  private

  class RenderContext
    def initialize(page)
      @page = page
    end

    private

    attr_reader :page

    # Partial rendering
    def render(partial_path, **locals)
      partial_full_path = File.join(page.config.partials_full_path, "#{partial_path}.html.erb")

      Tilt.new(partial_full_path).render(self, locals)
    end

    def method_missing(method_name, *args, &block)
      if page.respond_to?(method_name, true)
        page.send(method_name, *args, &block)
      else
        super
      end
    rescue NameError => e
      raise NameError, "Undefined method or local variable '#{method_name}' for #{page.class.name} (#{e.message})"
    end
  end
  def render_context = @render_context ||= RenderContext.new(self)

  def layout_template
    @layout_template ||=
      Tilt.new(File.join(config.layouts_full_path, "#{self.class.layout_path}.html.erb"))
  end
  def render_layout(&block)
    layout_template.render(render_context, &block)
  end
end
