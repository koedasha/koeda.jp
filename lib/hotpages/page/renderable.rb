module Hotpages::Page::Renderable
  def render_layout? = layout_path && !layout_path.empty? && page_template.rendered_to_html?
  def template_file_exist? = page_template.render_file?

  def page_template
    @page_template ||= begin
      if !template_extension.nil? # `nil` if no template file is provided
        Hotpages::Page::Template.new(@template_extension, base_path:, directory: site.pages_path)
      else
        Hotpages::Page::Template.new(body_type) { body }
      end
    end
  end

  # Rendering hook, can be overridden by subclasses
  def before_render; end

  def render
    before_render

    # For capturing contents for rendering, render page first
    page_content = page_template.render_in(rendering_context)

    rendering_context.cached_page_content = page_content

    if render_layout?
      rendering_context.render(File.join(site.layouts_dir, layout_path.to_s))
    else
      page_content
    end
  end

  private

  def rendering_context = @rendering_context ||= RenderingContext.new(self)

  class RenderingContext
    attr_reader :captured_contents
    attr_accessor :cached_page_content

    def initialize(page)
      @page = page
      @template_finder = Hotpages::Page::Template::Finder.new(page.base_path, page.site)
      @cached_page_content = nil
      @captured_contents = {}
    end

    def buffer = @buf

    # TODO: support ruby objects responds to `render_in`
    def render(template_path, **locals, &block)
      template = template_finder.find!(template_path)

      # TODO: block ignored warnings
      if block_given?
        template.render_in(self, locals, &block)
      else
        template.render_in(self, locals) do |content_name = nil|
          if content_name
            captured_contents[content_name.to_sym]
          else
            cached_page_content
          end
        end
      end
    end

    private

    attr_reader :page, :template_finder

    def respond_to_missing?(name, include_private = false)
      page.respond_to?(name, include_private)
    end

    def method_missing(method, *args, **kwargs, &block)
      page.send(method, *args, **kwargs, &block)
    end
  end
end
