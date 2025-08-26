module Hotpages::Extensions::TemplatePathAnnotation
  extend Hotpages::Extension

  prepending to: "Hotpages::Page::Template"

  def render_in(context, locals = {}, &block)
    content = super
    return content if !rendered_to_html? || Hotpages.site.generating?

    <<~HTML.chomp
      <!-- BEGIN #{abs_name} -->
      #{content}
      <!-- END #{abs_name} -->
    HTML
  end
end
