require "fileutils"

class Hotpages::Site::Generator
  CSS_IMPORT_REGEXP = /@import\s+(?:url\()?["']?([^"')]+)["']?\)?/.freeze

  def initialize(site:)
    @site = site
    @generating = false
  end

  def generate
    self.generating = true

    FileUtils.rm_rf(site.dist_path) if Dir.exist?(site.dist_path)

    generate_pages
    generate_assets

    self.generating = false
  end

  def generating? = generating

  private

  attr_reader :site
  attr_accessor :generating

  def generate_pages
    all_page_files = Dir.glob(site.pages_path.join("**/*"))
    page_instances = Hotpages.page_base_class.from_absolute_paths(all_page_files)

    page_instances.each do |page_instance|
      path_to_write = page_instance.expanded_base_path_with_extension
      file_path = site.dist_path.join(path_to_write)
      with_logging("PAGE(locale:#{page_instance.locale || "none"})", file_path) do
        content = page_instance.render
        write_file(file_path, content)
      end
    end
  end

  def generate_assets(
    src: site.assets_path,
    dist: site.dist_path.join(site.assets_dir)
  )
    # Process CSSs
    Dir.glob(src.join("**/*.css")).each do |css_file|
      dist_file = css_file.sub(src.to_s, dist.to_s)
      with_logging("ASSET(CSS)", dist_file) do
        content = File.read(css_file)
        # Add cache buster to @import URLs
        content = content.gsub(CSS_IMPORT_REGEXP) do |match|
          url = $1
          asset = Hotpages::Asset.new(url, directory: File.dirname(css_file))
          match.gsub(url, asset.digested_location)
        end

        write_file(dist_file, content)
      end
    end

    # Copy other asset files as-is
    Dir.glob(src.join("**/*")).each do |file|
      next if File.directory?(file) || file.end_with?(".css")
      dist_file = file.sub(src.to_s, dist.to_s)
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

  def with_logging(label, path)
    puts "[#{label}] Generating #{path}..."
    yield
    puts "[#{label}] Wrote #{path}"
  end
end
