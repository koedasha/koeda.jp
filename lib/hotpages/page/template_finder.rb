class Hotpages::Page::TemplateFinder
  def initialize(base_path, config)
    @base_path = base_path
    @config = config
    @base_dir = File.join(config.site.pages_full_path, File.dirname(base_path))
    @shared_dir = config.site.shared_full_path
  end

  def find_for(template_path)
    dirname = File.dirname(template_path)
    basename = "_#{File.basename(template_path)}"

    prioritized_search_paths = [
      !dirname.start_with?("/") ? File.join(base_dir, dirname, basename) : nil,
      File.join(shared_dir, dirname, basename)
    ].compact.map { File.expand_path(_1) }

    prioritized_search_paths.each do |path|
      if file = Dir.glob("#{path}.*").find { File.file?(_1) }
        return file
      else
        next
      end
    end

    raise "Cannot find template in: #{prioritized_search_paths}"
  end

  private

  attr_reader :base_dir, :shared_dir
end
