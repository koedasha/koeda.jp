require "tilt"
require "erubi"
require "erubi/capture_block"

module Hotpages::Page::Renderable
  include Hotpages::Helpers::CaptureHelper

  def render(partial_path = nil, **locals)
    return render_partial(partial_path, **locals) if partial_path

    page_content = new_tilt("erb") { body }.render(self)

    render_layout do |content_name = nil|
      if content_name
        content_for(content_name)
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

  def render_partial(partial_path, **locals)
    partial_full_path = File.join(config.partials_full_path, "#{partial_path}.html.erb")

    new_tilt(partial_full_path).render(self, locals)
  end

  def layout_template
    @layout_template ||=
      new_tilt(File.join(config.layouts_full_path, "#{self.class.layout_path}.html.erb"))
  end
  def render_layout(&block)
    layout_template.render(self, &block)
  end
end
