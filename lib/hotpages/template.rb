require "tilt"
require "erubi/capture_block"

Tilt.register(Tilt::PlainTemplate, "txt")
Tilt.register(Tilt::PlainTemplate, "xml")

class Hotpages::Template
  ERB_OPTIONS = { engine_class: Erubi::CaptureBlockEngine, bufvar: "@buf" }.freeze

  def initialize(extension, base_path: nil, directory: nil, &body)
    @extension = extension || ""
    @base_path = base_path
    @directory = directory

    @name = [ base_path, extension ].compact.join(".").chomp(".")
    @abs_name = File.join(*[ directory, @name ].compact)
    @body = body
  end

  def render_file? = !base_path.nil?
  def rendered_to_html? = extension.start_with?("html")
  def render_in(context, locals = {}, &block) = tilt.render(context, locals, &block)

  private

  attr_reader :extension, :base_path, :directory, :name, :abs_name, :body

  def extensions = @extensions ||= extension.split(".")

  def tilt = @tilt ||= new_tilt(&body)

  def new_tilt(&block)
    if extensions.empty?
      # When extension is not provided, use PlainTemplate
      Tilt::PlainTemplate.new(abs_name, &block)
    elsif extensions.length > 1
      options = if extensions.include?("erb")
        { "erb" => ERB_OPTIONS }
      else
        {}
      end

      # TODO: Correctly handle registering pipelines
      Tilt.register_pipeline(extension, options)
      Tilt.new(abs_name, &block)
    elsif extensions.include?("erb")
      Tilt.new(abs_name, **ERB_OPTIONS, &block)
    else
      Tilt.new(abs_name, &block)
    end
  end
end
