class Hotpages::SiteGenerator
  def initialize(config:)
    @config = config
  end

  def generate
    page_ruby_files = Dir.glob(File.join(config.pages_full_path, "**", "*.rb"))
    page_ruby_files.each do |file|
      relative_path = file.sub(config.pages_full_path + "/", "")
      page_name = relative_path.sub(".rb", "")
      puts "Generating page: #{page_name}"

      # Instantiate the page class
      page_class = Object.const_get("#{config.pages_namespace}::#{page_name.split('/').map(&:capitalize).join('::')}")
      page_instance = page_class.new(base_path: page_name, config:)

      # Render the page (assuming it has a render method)
      if page_instance.respond_to?(:render)
        puts page_instance.render
      else
        puts "No render method defined for #{page_name}"
      end
    end
  end

  private

  attr_reader :config
end
