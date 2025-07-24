class Hotpages::Page::PartialFinder
  Partial = Data.define(:base_path, :extension) do
    def self.from_full_path(full_path)
      fragments = full_path.split(".")
      base_path = fragments.first
      extensions = fragments[1..]
      new(base_path, extensions.join("."))
    end
  end

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
        return Partial.from_full_path(file)
      else
        next
      end
    end

    raise "Cannot find template in: #{search_paths}"
  end

  private

  attr_reader :base_dir, :partials_dir
end
