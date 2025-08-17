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
      rendering_context.render(File.join(site.directory.layouts, layout_path.to_s))
    else
      page_content
    end
  end

  private

  def rendering_context = @rendering_context ||= Hotpages::Page::RenderingContext.new(self)
end
