class Hotpages::Page::Template::Finder
  PathData = Data.define(:base_path, :extension) do
    def self.from_absolute_path(absolute_path)
      fragments = absolute_path.split(".")
      base_path = fragments.first
      extensions = fragments[1..]
      new(base_path, extensions.join("."))
    end
  end

  def initialize(base_path, config)
    @base_path = base_path
    @config = config
    @base_dir = File.join(config.site.pages_absolute_path, File.dirname(base_path))
    @root_dir = config.site.root
  end

  def find_for(template_path)
    data = path_data_for(template_path)
    Hotpages::Page::Template.new(data.extension, base_path: data.base_path)
  end

  private

  attr_reader :base_dir, :root_dir

  def path_data_for(template_path)
    dirname = File.dirname(template_path)
    basename = File.basename(template_path)
    underscore_basename = "_#{basename}"

    search_paths = [
      !dirname.start_with?("/") ? File.join(base_dir, dirname, underscore_basename) : nil,
      File.join(root_dir, dirname, basename),
      File.join(root_dir, dirname, underscore_basename)
    ].compact.map { File.expand_path(_1) }

    search_paths.each do |path|
      if file = Dir.glob("#{path}.*").find { File.file?(_1) }
        return PathData.from_absolute_path(file)
      else
        next
      end
    end

    raise "Cannot find template in: #{search_paths}"
  end
end
