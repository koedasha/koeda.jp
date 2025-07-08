require "erb"

module Hotpages::Page
  class << self
    def included(base)
      base.extend(Forwardable)
    end
  end

  def initialize(base_path: nil, config: nil)
    @base_path = base_path
    @config = config
  end

  def render
    ERB.new(template).result(binding)
  end

  private

  attr_reader :base_path, :config

  def template = File.read(File.join(config.pages_full_path, "#{base_path}.html.erb"))
end
