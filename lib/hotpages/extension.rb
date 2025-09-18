module Hotpages::Extension
  class << self
    def setup(extensions:, config:)
      extensions.each { it.setup(config) }
    end
  end

  def setup(config, extension = self)
    @setup_block.call(Setup.new(config, extension))
  end

  private

  def extension(&setup_block)
    @setup_block = setup_block
  end

  class Setup
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
  private_constant :Setup
end
