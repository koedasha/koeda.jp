require "erb"

module Hotpages::Page
  class << self
    def included(base)
      base.extend(Forwardable)
    end

    # TODO: Handle case where page_class is not defined
    def instance_for(page_path, config:)
      namespace = config.pages_namespace_module
      page_class = namespace.const_get(page_path.split('/').map(&:capitalize).join('::'))
      page_class.new(base_path: page_path, config:)
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
