module Hotpages::Page::Renderable
  def render_layout? = layout_path && !layout_path.empty? && page_template.rendered_to_html?
  def template_file_exist? = page_template.render_file?

  def render
    # Page rendering flow starts from here
    self.rendering_context = Hotpages::Page::RenderingContext.new(self)

    run_hooks(:render) do
      rendering_context.copy_page_instance_variables!

      # For capturing contents for rendering, render page first
      page_content = page_template.render_in(rendering_context)

      rendering_context.cached_page_content = page_content

      if render_layout?
        rendering_context.render(File.join(site.directory.layouts, layout_path.to_s))
      else
        page_content
      end
    end
  end

  private

  attr_accessor :rendering_context

  def page_template
    @page_template ||= begin
      if template_file_ext.nil? # `nil` if no template file is provided
        Hotpages::Template.new(body_type) { body }
      else
        Hotpages::Template.new(template_file_ext, base_path:, directory: site.pages_path, template_names:)
      end
    end
  end

  def template_names
    file_extensions = template_file_ext.split(".")

    if config.page_file_types.include?(file_extensions.first)
      file_extensions[1..]
    else
      file_extensions
    end
      .reverse
  end
end
