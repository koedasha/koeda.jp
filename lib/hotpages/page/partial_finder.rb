class Hotpages::Page::PartialFinder
  def initialize(base_path, config)
    @base_path = base_path
    @config = config
    @base_dir = File.join(config.site.pages_full_path, File.dirname(base_path))
    @partials_dir = config.site.partials_full_path
  end

  def find_for(partial_path)
    dirname = File.dirname(partial_path)
    basename = "_#{File.basename(partial_path)}"

    search_paths = [
      !dirname.start_with?("/") ? File.join(base_dir, dirname, basename) : nil,
      File.join(partials_dir, dirname, basename)
    ].compact.map { File.expand_path(_1) }

    search_paths.each do |path|
      if file = Dir.glob("#{path}.*").find { File.file?(_1) }
        return file
      else
        next
      end
    end

    raise "Cannot find template in: #{search_paths}"
  end

  private

  attr_reader :base_dir, :partials_dir
end
