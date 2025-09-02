module Hotpages::Extensions::DevServer::TemplatePathAnnotation
  extend Hotpages::Extension

  prepending to: "Hotpages::Template"

  def render_in(context, locals = {}, &block)
    content = super
    return content if !rendered_to_html?

    <<~HTML.chomp
      <!-- BEGIN #{abs_name} -->
      #{content}
      <!-- END #{abs_name} -->
    HTML
  end
end
