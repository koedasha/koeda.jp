require "tilt"
require "erubi/capture_block"

Tilt.register(Tilt::PlainTemplate, "txt")
Tilt.register(Tilt::PlainTemplate, "xml")

class Hotpages::Page::Template
  ERB_OPTIONS = { engine_class: Erubi::CaptureBlockEngine, bufvar: "@buf" }

  def initialize(extension, base_path: nil, directory: nil, &body)
    @extension = extension || ""
    @base_path = base_path
    @directory = directory

    @name = [base_path, extension].compact.join(".").chomp(".")
    @absolute_path = File.join(*[directory, @name].compact)
    @body = body
  end

  def render_file? = !base_path.nil?
  def file_last_modified_at = render_file? ? File.mtime(absolute_path) : nil
  def rendered_to_html? = extension.start_with?("html")
  def render_in(context, locals = {}, &block) = tilt.render(context, locals, &block)

  private

  attr_reader :extension, :base_path, :directory, :name, :absolute_path, :body

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
