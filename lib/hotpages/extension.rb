module Hotpages::Extension
  class Spec
    Entry = Data.define(:type, :base, :with) do
      def apply!
        base, with = get_consts
        case type
        when :prepend
          base.prepend(with)
          if with.const_defined?(:ClassMethods, false)
            base.extend(with::ClassMethods)
          end
        else
          raise "Unknown extension type: #{type}"
        end
      end

      private

      def get_consts
        b = Object.const_get(base)
        w = Hotpages::Extensions.const_get(with, false)
        [ b, w ]
      end
    end

    def prepending(with, to:) = add_entry(Entry.new(:prepend, to, with))

    def apply_all! = entries_by_base.each { |_, entries| entries.each(&:apply!) }
    def apply_to!(base) = entries_by_base[base]&.each(&:apply!)

    def bases = entries_by_base.keys

    private

    def entries_by_base = @entries_by_base ||= {}
    def add_entry(entry)
      entries_by_base[entry.base] ||= []
      entries_by_base[entry.base] << entry
    end
  end

  def spec = @spec ||= Spec.new
  def prepending(with, to:) = spec.prepending(with, to:)

  def setup!(zeitwerk_loader)
    spec.apply_all!

    spec.bases.each do |base|
      zeitwerk_loader.on_load(base) do |klass, _abspath|
        spec.apply_to!(klass.name)
      end
    end
  end
end
