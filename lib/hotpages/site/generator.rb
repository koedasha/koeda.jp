require "fileutils"
require "benchmark"

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
    page_instances = Hotpages::Page.all

    page_instances.each do |page_instance|
      path_to_write = page_instance.expanded_base_path_with_extension
      file_path = site.dist_path.join(path_to_write)
      locale_string = page_instance.respond_to?(:locale) ? "(locale: #{page_instance.locale || 'none'})" : ""
      with_logging("PAGE#{locale_string}", file_path) do
        content = page_instance.render
        write_file(file_path, content)
      end
    end
  end

  def generate_assets(
    dist: site.dist_path.join(site.config.assets.prefix.delete_prefix("/"))
  )
    # Process CSSs
    site.assets(".css").each do |base_path, css_file|
      dist_file = css_file.sub(base_path.to_s, dist.to_s)
      with_logging("ASSET(CSS)", dist_file) do
        content = File.read(css_file)
        # Add cache buster to @import URLs
        content = content.gsub(CSS_IMPORT_REGEXP) do |match|
          url = $1
          asset = Hotpages::Asset.new(url, directory: File.dirname(css_file))
          match.gsub(url, asset.digested_url)
        end

        write_file(dist_file, content)
      end
    end

    # Copy other asset files as-is
    site.assets.each do |base_path, file|
      next if File.directory?(file) || file.end_with?(".css")
      dist_file = file.sub(base_path.to_s, dist.to_s)
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
    duration = Benchmark.realtime { yield }
    puts "[#{label}] Wrote #{path} (#{(duration * 1000).round(4)} msec)"
  end
end
