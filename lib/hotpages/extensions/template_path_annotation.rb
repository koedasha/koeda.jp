module Hotpages::Extensions::TemplatePathAnnotation
  extend Hotpages::Extension

  prepending to: "Hotpages::Page::Template"

  def render_in(context, locals = {}, &block)
    content = super
    return content if Hotpages.site.generating?

    [
      "<!-- BEGIN #{abs_name} -->",
      content,
      "<!-- END #{abs_name} -->"
    ].join("\n")
  end
end
