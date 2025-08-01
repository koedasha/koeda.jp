require "singleton"
require "forwardable"

class Hotpages::Site
  include Singleton
  extend Forwardable

  class << self
    def config = @config ||= Hotpages.config
  end

  attr_reader :config

  def initialize
    @config = self.class.config
    @loader = Loader.new(config:)
    @generator = Generator.new(config:)
  end

  delegate %i[ setup reload ] => :loader
  def teardown
    loader.unload
    loader.unregister
  end

  delegate %i[ generate generating? ] => :generator

  private

  attr_accessor :loader, :generator
end
