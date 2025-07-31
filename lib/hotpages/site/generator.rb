require "fileutils"

class Hotpages::Site::Generator
  attr_reader :assets_version

  def initialize(config:)
    @config = config
    @generating = false
    @assets_version = nil
  end

  def generate(assets_version: nil)
    self.assets_version = assets_version || SecureRandom.hex(4)
    self.generating = true

    FileUtils.rm_rf(config.site.dist_full_path) if Dir.exist?(config.site.dist_full_path)

    all_page_files = Dir.glob(File.join(config.site.pages_full_path, "**/*"))
    page_instances = config.page_base_class.from_full_paths(all_page_files)

    page_instances.each do |page_instance|
      path_to_write = page_instance.expanded_base_path_with_extension
      puts "Generating page: #{path_to_write}"

      content = page_instance.render
      file_path = File.join(config.site.dist_full_path, path_to_write)

      FileUtils.mkdir_p(File.dirname(file_path))
      File.open(file_path, "w+b") { |f| f.write(content) }

      puts "Generated #{path_to_write}"
    end

    # Copy assets
    assets_src = config.site.assets_full_path
    assets_dest = config.site.dist_full_path
    FileUtils.cp_r(assets_src, assets_dest)
    puts "Copied assets to #{assets_dest}"

    self.generating = false
  end

  def generating? = generating

  private

  attr_reader :config
  attr_accessor :generating
  attr_writer :assets_version

  def remove_ext(path)
    basename = File.basename(path)
    basename_without_exts = basename.sub(/\..*$/, '')
    File.join(File.dirname(path), basename_without_exts)
  end
end
