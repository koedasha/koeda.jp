class Hotpages::Site
  class << self
    def instance = @instance ||= new
    def config = @config ||= Hotpages.config
  end

  attr_reader :config

  def initialize
    @config = self.class.config
    @loader = Loader.new(config:)
    @generator = Generator.new(config:)
  end

  def setup
    loader.setup
  end

  def teardown
    loader.unload
    loader.unregister
  end

  def reload
    loader.reload
  end

  def generate = generator.generate

  private

  attr_accessor :loader, :generator
end
