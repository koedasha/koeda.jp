class Hotpages::Site
  class << self
    def config = @config ||= Hotpages.config
    def configure
      yield(config) if block_given?
      loader.setup
    end

    def reload = loader.reload

    def generate = generator.generate

    private

    def loader
      @loader ||= Hotpages::SiteLoader.new(pages_namespace: config.pages_namespace_module, config:)
    end

    def generator
      @generator ||= Hotpages::SiteGenerator.new(config:)
    end
  end
end
