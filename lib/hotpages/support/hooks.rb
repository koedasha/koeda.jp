module Hotpages::Support::Hooks
  Type = Data.define(:type) do
    class << self
      def before = new(:before)
      def after = new(:after)
      def around = new(:around)
      def all = [ before, after, around ]
    end

    def key(hook) = "#{type}_#{hook}"
    def in?(*types) = types.include?(type)
  end
  private_constant :Type

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def inherited(subclass)
      super

      self.hooks.each do |key, hooks|
        # hooks array should be dupped, but inner procs aren't
        subclass.hooks[key] = hooks.dup
      end
    end

    def hooks = @hooks ||= {}
    attr_writer :hooks

    def define_hook(hook_name, only: nil)
      Type.all.each do |type|
        registered_name = type.key(hook_name)
        hooks[registered_name] = []

        if only.nil? || type.in?(only)
          define_singleton_method(registered_name) do |method_name = nil, &block|
            hooks[registered_name] << (method_name || block)
          end
        end
      end
    end
    def define_hooks(*hook_names, only: nil)
      hook_names.each do |name|
        define_hook(name, only:)
      end
    end
  end

  def run_hooks(hook_name, &block)
    unless self.class.hooks[Type.before.key(hook_name)]
      raise "Hooks for `#{hook_name}` is not registered."
    end

    self.class.hooks[Type.before.key(hook_name)].each do |hook_content|
      callable_hook_content(hook_content).call
    end

    # Around hooks are called in reverse order of their definition (from the last defined to the first).
    around_hooks = self.class.hooks[Type.around.key(hook_name)].map do |hook_content|
      callable_hook_content(hook_content)
    end
    result = nil
    if around_hooks.any?
      around_hooks.inject(block) do |inner, outer|
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
      ->(inner_proc = nil) { instance_exec(*[ self, inner_proc ].compact, &hook_content) }
    else
      raise "Unsupported hook: #{hook_content.inspect}"
    end
  end
end
