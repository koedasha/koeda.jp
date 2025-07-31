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

  def_delegators :loader, :setup, :reload
  def teardown
    loader.unload
    loader.unregister
  end

  def_delegators :generator, :generate, :generating?, :assets_version

  private

  attr_accessor :loader, :generator
end
