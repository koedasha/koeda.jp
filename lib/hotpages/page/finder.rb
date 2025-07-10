class Hotpages::Page::Finder
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def find_for(requested_path)
    # Normalized as `foo/bar/index'
    page_path = normalize_path(requested_path)
    page_class = constantize_path(page_path)

    if page_class
      page_class.new(base_path: page_path)
    else
      dirname = File.dirname(page_path)

      expandable_files = Dir.glob(File.join(config.pages_full_path, dirname, "_*"))
      page_instances = config.page_base_class.from_full_paths(expandable_files)
      page_instances.find { |page| page.expanded_base_path == page_path }
    end
  end

  private

  def normalize_path(path)
    path = "#{path}index" if path.end_with?("/")
    path = path.sub(%r{^/}, '') # Remove leading slash if present
    path
  end

  def constantize_path(path)
    const_name = path.split('/').map(&:capitalize).join('::')
    config.pages_namespace_module.const_get(const_name) rescue nil
  end
end
