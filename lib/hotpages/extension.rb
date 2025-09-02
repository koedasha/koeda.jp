module Hotpages::Extension
  class << self
    def setup(extensions: Hotpages.extensions, config: Hotpages.config)
      extensions.each { it.setup(config) }
    end
  end

  def setup(config, extension_mod = self)
    @spec_block.call(Spec.new(config, extension_mod))
  end

  private

  def spec(&spec_block)
    @spec_block = spec_block
  end

  class Spec
    def initialize(config, extension)
      @config = config
      @extension = extension
    end

    def prepend(mod = extension, to:)
      to.prepend(mod)
      if mod.const_defined?(:ClassMethods)
        to.singleton_class.prepend(mod::ClassMethods)
      end
    end

    def include(mod = extension, to:)
      to.include(mod)
      if mod.const_defined?(:ClassMethods)
        to.extend(mod::ClassMethods)
      end
    end

    def add_helper(helper_mod) = include(helper_mod, to: Hotpages::Page)

    def configure = yield config

    private

    attr_reader :config, :extension
  end
  private_constant :Spec
end
