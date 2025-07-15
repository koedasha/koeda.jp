require "tilt"
require "erubi"
require "erubi/capture_block"

module Hotpages::Page::Renderable
  TEMPLATE_BASENAME_REGEXP = /\A_.*/.freeze

  Tilt.register(Tilt::PlainTemplate, "txt")

  def template_name = [base_path, template_extension].join(".")
  def template_full_path = File.join(config.site.pages_full_path, template_name)
  def template_exists? = File.exist?(template_full_path)
  def rendered_to_html?
    template_extension.nil? || template_extension.start_with?("html")
  end
  def render_layout? = rendered_to_html?

  def render(partial_path = nil, **partial_locals)
    return render_partial(partial_path, **partial_locals) if partial_path

    page_content = template.render(self)

    render_layout do |content_name = nil|
      if content_name
        captured_contents[content_name.to_sym]
      else
        page_content
      end
    end
  end

  private

  def template
    @template ||= if template_exists?
      new_tilt(template_full_path)
    else
      new_tilt(template_extension || body_type) { body }
    end
  end

  def new_tilt(template_path, &block)
    extensions = block_given? ? template_path.split(".") : template_path.split(".")[1..]
    erb_options = { engine_class: Erubi::CaptureBlockEngine, bufvar: "@buf" }

    # TODO: Correctly handle registering pipelines
    if extensions.length > 1
      options = if extensions.include?("erb")
                  { "erb" => erb_options }
                else
                  {}
                end

      Tilt.register_pipeline(extensions.join("."), options)
      Tilt.new(template_path, &block)
    elsif extensions.include?("erb")
      Tilt.new(template_path, **erb_options, &block)
    else
      Tilt.new(template_path, &block)
    end
  end

  def captured_contents = @captured_contents ||= {}

  def partial_finder = @partial_finder ||= Hotpages::Page::PartialFinder.new(base_path, config)
  def render_partial(partial_path, **locals)
    partial_full_path = partial_finder.find_for(partial_path)
    new_tilt(partial_full_path).render(self, locals)
  end

  def layout_template
    @layout_template ||=
      new_tilt(File.join(config.site.layouts_full_path, "#{layout_path}.html.erb"))
  end
  def render_layout(&block)
    if !render_layout? || layout_path.nil? || layout_path.empty?
      yield if block_given?
    else
      layout_template.render(self, &block)
    end
  end
end
