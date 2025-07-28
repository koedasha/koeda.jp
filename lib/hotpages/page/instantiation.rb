module Hotpages::Page::Instantiation
  include Hotpages::Page::Expandable

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def from_full_paths(paths)
      files = paths.map { File.expand_path(_1) }.select { |f| File.file?(f) }
      base_path_exts_map = files.group_by { |file| remove_ext(file) }.transform_values do |files|
        files.map { |file| (File.basename(file).split('.')[1..] || []).join('.') }
      end
      base_path_exts_map.flat_map do |base_path, exts|
        non_rb_exts = exts.reject { |ext| ext == "rb" }

        raise "Multiple page templates found for #{base_path}: #{non_rb_exts.join(', ')}" if non_rb_exts.size > 1

        from_path(base_path, template_extension: non_rb_exts.first) || []
      end
    end

    private

    def from_path(base_path, template_extension:)
      filename = File.basename(base_path)

      return nil if filename =~ Hotpages::Page::Renderable::TEMPLATE_BASENAME_REGEXP

      page_base_path = base_path.sub(config.site.pages_full_path + "/", "")

      class_name = page_base_path.classify
      page_class_defined = config.site.pages_namespace_module.const_defined?(class_name, false)
      page_class =
        if page_class_defined
          config.site.pages_namespace_module.const_get(class_name, false)
        else
          page_subclass_under(class_name.split("::")[...-1])
        end

      if page_class.respond_to?(:expand_instances_for)
        page_class.expand_instances_for(page_base_path, template_extension:)
      else
        nil
      end
    end

    def remove_ext(path)
      basename = File.basename(path)
      basename_without_exts = basename.sub(/\..*$/, '')
      File.join(File.dirname(path), basename_without_exts)
    end

    def page_subclass_under(
      namespaces,
      root_module: config.site.pages_namespace_module,
      parent_class: config.page_base_class,
      class_name: "Page_"
    )
      ns = namespaces.inject(root_module) do |ns, namespace|
        ns.const_defined?(namespace) ? ns.const_get(namespace) : ns.const_set(namespace, Module.new)
      end

      ns.const_defined?(class_name) ? ns.const_get(class_name) :
                                      ns.const_set(class_name, Class.new(parent_class))
    end
  end
end
