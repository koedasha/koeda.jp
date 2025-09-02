module Hotpages::Extension
  class << self
    def setup(extensions: Hotpages.extensions, config: Hotpages.config)
      extensions.each { it.setup(config) }
    end
  end

  def setup(config)
    @spec_block.call(Spec.new(config))
  end

  private

  def spec(&spec_block)
    @spec_block = spec_block
  end

  class Spec
    def initialize(config)
      @config = config
    end

    def prepend(mod, to:)
      to.prepend(mod)
      if mod.const_defined?(:ClassMethods)
        to.singleton_class.prepend(mod::ClassMethods)
      end
    end

    def include(mod, to:)
      to.include(mod)
      if mod.const_defined?(:ClassMethods)
        to.extend(mod::ClassMethods)
      end
    end

    def add_helper(helper_mod) = include(helper_mod, to: Hotpages::Page)

    def configure = yield config

    private

    attr_reader :config
  end
  private_constant :Spec
end
