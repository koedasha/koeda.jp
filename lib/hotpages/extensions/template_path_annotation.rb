module Hotpages::Extensions::TemplatePathAnnotation
  extend Hotpages::Extension

  spec do
    it.prepend to: Hotpages::Template
  end

  def render_in(context, **locals, &block)
    content = super
    return content if !rendered_to_html?

    <<~HTML.chomp
      <!-- BEGIN #{abs_name} -->
      #{content}
      <!-- END #{abs_name} -->
    HTML
  end
end
