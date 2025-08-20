# Sample site specific extension
module TemplatePathAnnotation
  extend Hotpages::Extension

  prepending to: "Hotpages::Page::RenderingContext"

  def render(template_path, **locals, &block)
    content = super
    return content if Hotpages.site.generating?

    template = template_finder.find!(template_path)
    annotation = "<!-- #{template.send(:abs_name)} -->"
    [ annotation, content ].join("\n")
  end
end
