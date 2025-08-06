module Hotpages::Page::Renderable
  def render_layout? = layout_path && !layout_path.empty? && page_template.rendered_to_html?

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

  def captured_contents = @captured_contents ||= {}
  def rendering_context = @rendering_context ||= self.extend(TemplateRendering)

  module TemplateRendering
    attr_accessor :cached_page_content

    # TODO: support ruby objects responds to `render_in`
    def render(template_path, **locals, &block)
      template = template_finder.find!(template_path)

      # TODO: block ignored warnings
      if block_given?
        template.render_in(rendering_context, locals, &block)
      else
        template.render_in(rendering_context, locals) do |content_name = nil|
          if content_name
            captured_contents[content_name.to_sym]
          else
            cached_page_content
          end
        end
      end
    end

    private

    def template_finder = @template_finder ||= Hotpages::Page::Template::Finder.new(base_path, site)
  end
end
