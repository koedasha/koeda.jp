module Hotpages::Support::Hooks
  Type = Data.define(:type) do
    class << self
      def before = new(:before)
      def after = new(:after)
      def around = new(:around)
      def all = [ before, after, around ]
    end

    def key(hook) = "#{type}_#{hook}"
  end

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    using Hotpages::Support::DeepDup

    def inherited(subclass)
      super
      subclass.hooks = self.hooks.deep_dup
    end

    def hooks = @hooks ||= {}
    attr_writer :hooks

    def define_hook(hook_name) = define_hooks(hook_name)
    def define_hooks(*hook_names)
      hook_names.each do |name|
        Type.all.each do |type|
          registered_name = type.key(name)
          hooks[registered_name] = []
          define_singleton_method registered_name do |method_name = nil, &block|
            hooks[registered_name] << (method_name || block)
          end
        end
      end
    end
  end

  def with_calling_hooks(hook_name, &block)
    self.class.hooks[Type.before.key(hook_name)].each do |hook_content|
      callable_hook_content(hook_content).call
    end

    # Around hooks are called in reverse order of their definition (from the last defined to the first).
    around_methods = self.class.hooks[Type.around.key(hook_name)].map do |hook_content|
      callable_hook_content(hook_content)
    end
    result = nil
    if around_methods.any?
      around_methods.inject(block) do |inner, outer|
        proc do
          outer.call(
            proc do
              if inner == block
                result = block.call
              else
                inner.call
              end
            end
          )
        end
      end.call
    else
      result = block.call
    end

    self.class.hooks[Type.after.key(hook_name)].each do |hook_content|
      callable_hook_content(hook_content).call
    end

    result
  end

  private

  def callable_hook_content(hook_content)
    case hook_content
    when Symbol
      method(hook_content)
    when Proc
      ->(*args) { instance_exec(*args, &hook_content) }
    else
      raise "Unsupported hook: #{hook_content.inspect}"
    end
  end
end
