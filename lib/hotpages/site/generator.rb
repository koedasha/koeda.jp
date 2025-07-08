class Hotpages::Site::Generator
  def initialize(config:)
    @config = config
  end

  def generate
    FileUtils.rm_rf(config.dist_full_path) if Dir.exist?(config.dist_full_path)

    page_ruby_files = Dir.glob(File.join(config.pages_full_path, "**", "*.rb"))
    page_ruby_files.each do |file|
      relative_path = file.sub(config.pages_full_path + "/", "")
      page_path = relative_path.sub(".rb", "")
      puts "Generating page: #{page_path}"

      # Instantiate the page class
      page_instance = Hotpages::Page.instance_for(page_path, config:)

      # Render the page
      content = page_instance.render
      file_path = File.join(config.dist_full_path, "#{page_path}.html")
      FileUtils.mkdir_p(File.dirname(file_path))
      File.open(file_path, "w+b") { |f| f.write(content) }

      puts "Generated #{page_path}.html"
    end
  end

  private

  attr_reader :config
end
