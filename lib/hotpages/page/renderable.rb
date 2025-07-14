require "tilt"
require "erubi"
require "erubi/capture_block"

module Hotpages::Page::Renderable
  TEMPLATE_BASENAME_REGEXP = /\A_.*/.freeze

  def render(template_path = nil, **template_locals)
    return render_template(template_path, **template_locals) if template_path

    page_content = new_tilt("erb") { body }.render(self)

    render_layout do |content_name = nil|
      if content_name
        captured_contents[content_name.to_sym]
      else
        page_content
      end
    end
  end

  private

  def new_tilt(template_path, &block)
    Tilt.new(template_path, engine_class: Erubi::CaptureBlockEngine, bufvar: "@buf", &block)
  end

  def captured_contents = @captured_contents ||= {}

  def template_finder = @template_finder ||= Hotpages::Page::TemplateFinder.new(base_path, config)
  def render_template(template_path, **locals)
    template_full_path = template_finder.find_for(template_path)
    new_tilt(template_full_path).render(self, locals)
  end

  def layout_template
    @layout_template ||=
      new_tilt(File.join(config.site.layouts_full_path, "#{self.class.layout_path}.html.erb"))
  end
  def render_layout(&block)
    layout_template.render(self, &block)
  end
end
