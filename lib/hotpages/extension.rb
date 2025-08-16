require "singleton"

module Hotpages::Extension
  using Hotpages::Refinements::String

  class Spec
    include Singleton

    Entry = Data.define(:type, :base, :with) do
      def apply!
        base, with = get_consts
        case type
        when :prepend
          base.prepend(with)
          if with.const_defined?(:ClassMethods, false)
            base.singleton_class.prepend(with::ClassMethods)
          end
        when :include
          base.include(with)
          if with.const_defined?(:ClassMethods, false)
            base.extend(with)
          end
        else
          raise "Unknown extension type: #{type}"
        end
      end

      private

      def get_consts
        [ base.constantize, with.constantize ]
      end
    end

    def prepending(with, to:) = add_entry(Entry.new(:prepend, to, with))
    def including(with, to:) = add_entry(Entry.new(:include, to, with))

    def apply_all! = entries_by_base.each { |_, entries| entries.each(&:apply!) }
    def apply_on!(base) = entries_by_base[base]&.each(&:apply!)

    def bases = entries_by_base.keys

    private

    def entries_by_base = @entries_by_base ||= {}
    def add_entry(entry)
      entries_by_base[entry.base] ||= []
      entries_by_base[entry.base] << entry
    end
  end

  class << self
    def setup!(loader: Hotpages.loader, spec: Spec.instance)
      spec.apply_all!
      spec.bases.each do |base|
        loader.on_load(base) do |klass, _abspath|
          spec.apply_on!(klass.name)
        end
      end
    end
  end

  def spec = Spec.instance

  def prepending(with = self.name, to:) = spec.prepending(with, to:)
  def including(with = self.name, to:) = spec.including(with, to:)

  def add_helpers(*added_helpers)
    added_helpers.each do |helper|
      including(helper, to: "Hotpages::Page")
    end
  end
  def add_helper(added_helper = self.name) = add_helpers(added_helper)
end
