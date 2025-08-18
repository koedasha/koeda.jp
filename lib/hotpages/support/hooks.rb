module Hotpages::Support::Hooks
  TYPES = {
    before: "before",
    after: "after",
    around: "around"
  }

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  def with_calling_hooks(hook_name, &block)
    self.class.hooks["#{TYPES[:before]}_#{hook_name}"].each do |meth_name|
      method(meth_name).call
    end

    # Around hooks are called in reverse order of their definition (from the last defined to the first).
    around_methods = self.class.hooks["#{TYPES[:around]}_#{hook_name}"].map do |meth_name|
      method(meth_name)
    end
    result = nil
    if around_methods.any?
      around_methods.inject(block) do |inner, outer|
        Proc.new do
          outer.call do
            if inner == block
              result = block.call
            else
              inner.call
            end
          end
        end
      end.call
    else
      result = block.call
    end

    self.class.hooks["#{TYPES[:after]}_#{hook_name}"].each do |meth_name|
      method(meth_name).call
    end

    result
  end

  module ClassMethods
    def inherited(subclass)
      super
      subclass.hooks = Marshal.load(Marshal.dump(self.hooks)) # deep dup
    end

    def hooks = @hooks ||= {}
    def hooks=(hooks)
      @hooks = hooks
    end

    def define_hook(hook_name) = define_hooks(hook_name)
    def define_hooks(*hook_names)
      hook_names.each do |name|
        TYPES.each do |_, type|
          registered_name = "#{type}_#{name}"
          hooks[registered_name] = []
          define_singleton_method registered_name do |hook_method_name|
            hooks[registered_name] << hook_method_name
          end
        end
      end
    end
  end
end
