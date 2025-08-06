require "fileutils"

class Hotpages::Site::Generator
  def initialize(config:)
    @config = config
    @generating = false
  end

  def generate
    self.generating = true

    FileUtils.rm_rf(config.site.dist_absolute_path) if Dir.exist?(config.site.dist_absolute_path)

    generate_pages
    generate_assets

    self.generating = false
  end

  def generating? = generating

  private

  attr_reader :config
  attr_accessor :generating

  def generate_pages
    all_page_files = Dir.glob(File.join(config.site.pages_absolute_path, "**/*"))
    page_instances = config.page_base_class.from_absolute_paths(all_page_files)

    page_instances.each do |page_instance|
      path_to_write = page_instance.expanded_base_path_with_extension
      file_path = File.join(config.site.dist_absolute_path, path_to_write)
      with_logging("PAGE", file_path) do
        content = page_instance.render
        write_file(file_path, content)
      end
    end
  end

  def generate_assets(
    src: config.site.assets_absolute_path,
    dist: File.join(config.site.dist_absolute_path, config.site.assets_dir)
  )
    # Process CSSs
    Dir.glob(File.join(src, "**/*.css")).each do |css_file|
      dist_file = css_file.sub(src, dist)
      with_logging("ASSET(CSS)", dist_file) do
        content = File.read(css_file)
        # Add cache buster to @import URLs
        content = content.gsub(/@import\s+(?:url\()?["']?([^"')]+)["']?\)?/) do |match|
          url = $1
          asset = Hotpages::Asset.new(url, directory: File.dirname(css_file))
          match.gsub(url, asset.digested_location)
        end

        write_file(dist_file, content)
      end
    end

    # Copy other asset files as-is
    Dir.glob(File.join(src, "**/*")).each do |file|
      next if File.directory?(file) || file.end_with?(".css")
      dist_file = file.sub(src, dist)
      with_logging("ASSET", dist_file) do
        FileUtils.mkdir_p(File.dirname(dist_file))
        FileUtils.cp(file, dist_file)
      end
    end
  end

  def write_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "w+b") { |f| f.write(content) }
  end

  def remove_ext(path)
    basename = File.basename(path)
    basename_without_exts = basename.sub(/\..*$/, '')
    File.join(File.dirname(path), basename_without_exts)
  end

  def with_logging(label, path)
    puts "[#{label}] Generating #{path}..."
    yield
    puts "[#{label}] Wrote #{path}"
  end
end
