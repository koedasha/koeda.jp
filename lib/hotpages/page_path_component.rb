class Hotpages::PagePathComponent
  using Hotpages::Support::StringInflections

  EXPANDABLE_NAME_REGEXP = /\A\[(.+)\]/.freeze

  class << self
    def site = Hotpages.site
    def config = Hotpages.config

    def segment_names = nil
    def expandable? = !!segment_names
    def subclass_at_path(path) = nil

    private

    def absolute_path_of(path)
      absolute_path = site.pages_path.to_s + path.to_s.delete_prefix(site.pages_path.to_s)
      Pathname.new(absolute_path)
    end

    # e.g.) foo/bar_baz => Page_Foo_BarBaz
    def class_name_for(path, prefix:)
      prefix + path.to_s.delete_prefix(site.pages_path.to_s + "/").delete("[]").classify.gsub("::", "_")
    end

    def new_subclass(name, with_definition:)
      klass = Class.new(self).tap do
        it.class_eval(with_definition) if with_definition
      end

      Object.send(:remove_const, name) if Object.const_defined?(name)
      Object.const_set(name, klass)
    end
  end
end
