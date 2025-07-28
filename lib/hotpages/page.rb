require "forwardable"

class Hotpages::Page
  extend Forwardable
  include Expandable, Instantiation, Renderable, Findable
  include Hotpages::Helpers

  class << self
    # Class wide configuration refers to Hotpages.config
    def config = @config ||= Hotpages.config

    def inherited(subclass)
      subclass.layout_path = self.layout_path.dup if self.layout_path
    end

    def layout(layout_path)
      @layout_path = layout_path
    end
    attr_accessor :layout_path
  end

  layout :site # Default layout path, can be overridden by individual pages

  attr_reader :base_path, :segments, :name, :config, :template_extension, :layout_path, :template

  def initialize(base_path:, segments: {}, name: nil, template_extension: nil, layout: nil)
    @base_path = base_path
    @segments = segments
    @name = name || base_path.split("/").last
    @config = self.class.config
    @template_extension = template_extension
    @layout_path = layout || self.class.layout_path

    @template ||=
      if !@template_extension.nil? # `nil` if no template file is provided
        Hotpages::Template.new(@template_extension, base_path:, path_prefix: config.site.pages_full_path)
      else
        Hotpages::Template.new(body_type) { body }
      end
  end

  def layout(layout_path)
    @layout_path = layout_path
  end

  def body
    raise "No template file is found for #{self.class.name} at #{base_path}, "\
          "please provide body method or template file."
  end
  def body_type = "html.erb"
end
