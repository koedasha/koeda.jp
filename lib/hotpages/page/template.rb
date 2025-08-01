require "tilt"
require "erubi/capture_block"

Tilt.register(Tilt::PlainTemplate, "txt")

class Hotpages::Page::Template
  ERB_OPTIONS = { engine_class: Erubi::CaptureBlockEngine, bufvar: "@buf" }

  def initialize(extension, base_path: nil, path_prefix: nil, &body)
    @extension = extension || ""
    @base_path = base_path
    @path_prefix = path_prefix

    @name = [base_path, extension].compact.join(".").chomp(".")
    @absolute_path = File.join(*[path_prefix, @name].compact)
    @body = body
  end

  def renders_file? = !base_path.nil?
  def rendered_to_html? = extension.start_with?("html")
  def render_in(context, locals = {}, &block) = tilt.render(context, locals, &block)

  private

  attr_reader :extension, :base_path, :path_prefix, :name, :absolute_path, :body

  def extensions = @extensions ||= extension.split(".")

  def tilt = @tilt ||= new_tilt(&body)

  def new_tilt(&block)
    if extensions.empty?
      # When extension is not provided, use PlainTemplate
      Tilt::PlainTemplate.new(absolute_path, &block)
    elsif extensions.length > 1
      options = if extensions.include?("erb")
                  { "erb" => ERB_OPTIONS }
                else
                  {}
                end

      # TODO: Correctly handle registering pipelines
      Tilt.register_pipeline(extension, options)
      Tilt.new(absolute_path, &block)
    elsif extensions.include?("erb")
      Tilt.new(absolute_path, **ERB_OPTIONS, &block)
    else
      Tilt.new(absolute_path, &block)
    end
  end
end
