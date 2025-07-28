class Hotpages::Page::Finder
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def find_for(requested_path)
    # Normalized as `foo/bar/index'
    page_path = normalize_path(requested_path)
    page_files = Dir.glob(File.join(config.site.pages_full_path, "**/*"))
    page_instances = config.page_base_class.from_full_paths(page_files)
    page_instances.find do |page|
      page.expanded_base_path_with_extension == page_path ||
        page.expanded_base_path_with_extension == add_extension_to(page_path)
    end
  end

  private

  def normalize_path(path)
    path = "#{path}index" if path.end_with?("/")
    path = path.sub(%r{^/}, '') # Remove leading slash if present
    path
  end

  def add_extension_to(page_path)
    return page_path if page_path.split("/").last.split(".").size > 1

    # Add .html extension by default
    "#{page_path}.html"
  end
end
