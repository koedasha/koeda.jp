class Hotpages::PagePathComponent
  using Hotpages::Support::StringInflections

  IGNORE_PATH_REGEXP = /\/_[^_]/.freeze
  EXPANDABLE_NAME_REGEXP = /\A\:([^\.]+)/.freeze

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

    # e.g.)
    # foo/bar_baz => Page_Foo_BarBaz
    # foo/:bar/:baz => Page_Foo__Bar__Baz
    def class_name_for(path, prefix:)
      prefix + path.to_s.delete_prefix(site.pages_path.to_s + "/").classify.gsub("::", "_").gsub(":", "_")
    end

    def new_subclass(name, ruby_file:, version:)
      site.cache.fetch(name, version:) do
        klass = Class.new(self).tap do
          it.class_eval(File.read(ruby_file)) if ruby_file
        end

        Object.send(:remove_const, name) if Object.const_defined?(name)
        Object.const_set(name, klass)
      end
    end

    def ignore_path?(path)
      path.to_s =~ IGNORE_PATH_REGEXP
    end
  end
end
