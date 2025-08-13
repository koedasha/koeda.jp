module Hotpages::Extension
  class Spec
    Entry = Data.define(:type, :base, :with) do
      def apply!
        base, with = get_consts
        case type
        when :prepend
          base.prepend(with)
          if with.const_defined?(:ClassMethods, false)
            base.singleton_class.prepend(with::ClassMethods)
          end
        else
          raise "Unknown extension type: #{type}"
        end
      end

      private

      def get_consts
        b = Object.const_get(base, false)
        w = Object.const_get(with, false)
        [ b, w ]
      end
    end

    def prepending(with, to:) = add_entry(Entry.new(:prepend, to, with))

    def apply_all! = entries_by_base.each { |_, entries| entries.each(&:apply!) }
    def apply!(base) = entries_by_base[base]&.each(&:apply!)

    def bases = entries_by_base.keys

    private

    def entries_by_base = @entries_by_base ||= {}
    def add_entry(entry)
      entries_by_base[entry.base] ||= []
      entries_by_base[entry.base] << entry
    end
  end

  def spec = @spec ||= Spec.new
  def prepending(with = self.name, to:) = spec.prepending(with, to:)
  def add_helpers(*added_helpers) = helpers.concat(added_helpers)

  using Hotpages::Refinements::String
  def setup!(hotpages_module)
    spec.apply_all!
    spec.bases.each do |base|
      hotpages_module.loader.on_load(base) do |klass, _abspath|
        spec.apply!(klass.name)
      end
    end

    hotpages_module.extension_helpers.concat(helpers.map(&:constantize))
  end

  private

  def helpers = @helpers ||= []
end
