class Hotpages::Site
  class << self
    def instance = @instance ||= new
    def config = @config ||= Configuration.new(Hotpages.config)
  end

  attr_reader :config, :dev_server

  def initialize
    @config = self.class.config
    @loader = Loader.new(config:)
    @generator = Generator.new(config:)
    @dev_server = DevServer.new(site: self, port: Hotpages.config.dev_server.port)
  end

  def setup
    loader.setup
  end

  def reload
    loader.reload
  rescue Zeitwerk::SetupRequired
    loader.setup
  ensure
    loader.reload
  end

  def generate = generator.generate

  private

  attr_accessor :loader, :generator
end
