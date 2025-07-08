class Hotpages::Site
  class << self
    def instance = @instance ||= new
    def config = @config ||= Hotpages.config
  end

  attr_reader :config, :dev_server

  def setup
    Hotpages.site = self

    @config = self.class.config
    @loader = Hotpages::SiteLoader.new
    @generator = Hotpages::SiteGenerator.new
    @dev_server = Hotpages::DevServer.new

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
