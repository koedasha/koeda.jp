require "forwardable"

class Hotpages::Page
  extend Forwardable, Instantiation
  include Expandable, Renderable
  include Hotpages::Helpers

  class << self
    # Pages dynamically generated and not defined in Ruby files are considered Phantom pages
    def phantom? = false

    def site = Hotpages.site
    def config = Hotpages.config

    def inherited(subclass)
      subclass.layout_path = self.layout_path.dup if self.layout_path
    end

    def layout(layout_path)
      @layout_path = layout_path
    end
    attr_accessor :layout_path

    def include_all_site_helpers
      site.helper_constants.each do |helper_module|
        next if included_modules.include?(helper_module)
        include helper_module
      end
    end
  end

  layout :site # Default layout path, can be overridden by individual pages

  attr_reader :base_path, :segments, :name, :site, :config, :template_extension, :layout_path

  def initialize(base_path:, segments: {}, name: nil, template_extension: nil, layout: nil)
    @base_path = base_path
    @segments = segments
    @name = name || base_path.split("/").last
    @site = self.class.site
    @config = self.class.config
    @template_extension = template_extension
    @layout_path = layout || self.class.layout_path

    # Include helpers dynamically here
    self.class.include_all_site_helpers
  end

  def layout(layout_path)
    @layout_path = layout_path
  end

  def body
    raise "No template file is found for #{self.class.name} at `/#{site.pages_dir}/#{base_path}`, "\
          "please provide body method or template file."
  end
  def body_type = "html.erb"

  def last_modified_at
    [ page_template.file_last_modified_at,
      ruby_file_last_modified_at ]
      .compact.max
  end

  private

  def ruby_file_last_modified_at
    path = site.pages_path.join(base_path, ".rb")
    File.file?(path) ? File.mtime(path) : nil
  end
end
