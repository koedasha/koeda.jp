module Hotpages::Support::Hooks
  Type = Data.define(:type) do
    class << self
      def before = new(:before)
      def after = new(:after)
      def around = new(:around)
      def all = [ before, after, around ]
    end

    def name_for(hook) = "#{type}_#{hook}"
  end

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  def with_calling_hooks(hook_name, &block)
    self.class.hooks[Type.before.name_for(hook_name)].each do |meth_name|
      method(meth_name).call
    end

    # Around hooks are called in reverse order of their definition (from the last defined to the first).
    around_methods = self.class.hooks[Type.around.name_for(hook_name)].map do |meth_name|
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

    self.class.hooks[Type.after.name_for(hook_name)].each do |meth_name|
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
    attr_writer :hooks

    def define_hook(hook_name) = define_hooks(hook_name)
    def define_hooks(*hook_names)
      hook_names.each do |name|
        Type.all.each do |type|
          registered_name = type.name_for(name)
          hooks[registered_name] = []
          define_singleton_method registered_name do |hook_method_name|
            hooks[registered_name] << hook_method_name
          end
        end
      end
    end
  end
end
