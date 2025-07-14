require "fileutils"

class Hotpages::Site::Generator
  def initialize(config:)
    @config = config
  end

  def generate
    FileUtils.rm_rf(config.site.dist_full_path) if Dir.exist?(config.site.dist_full_path)

    page_instances = config.page_base_class.from_full_paths(Dir.glob(File.join(config.site.pages_full_path, "**", "*")))

    page_instances.each do |page_instance|
      path_to_write = page_instance.expanded_base_path
      puts "Generating page: #{path_to_write}"

      content = page_instance.render
      file_path = File.join(config.site.dist_full_path, "#{path_to_write}.html")

      FileUtils.mkdir_p(File.dirname(file_path))
      File.open(file_path, "w+b") { |f| f.write(content) }

      puts "Generated #{path_to_write}.html"
    end

    # Copy assets
    assets_src = config.site.assets_full_path
    assets_dest = config.site.dist_full_path
    FileUtils.cp_r(assets_src, assets_dest)
  end

  private

  attr_reader :config

  def remove_ext(path)
    basename = File.basename(path)
    basename_without_exts = basename.sub(/\..*$/, '')
    File.join(File.dirname(path), basename_without_exts)
  end
end
