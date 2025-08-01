module Hotpages::Page::Instantiation
  IGNORED_PATH_REGEXP = /\/_[^_]/.freeze

  def from_absolute_paths(paths)
    base_paths = paths.inject([]) do |result, path|
      next result unless path.start_with?(config.site.pages_absolute_path)

      base_path = path.sub(config.site.pages_absolute_path + "/", "")

      next result if base_path =~ IGNORED_PATH_REGEXP

      absolute_path = File.expand_path(path)

      File.file?(absolute_path) ? result << base_path :result
    end

    base_path_exts_map = base_paths.group_by { |path| remove_ext(path) }.transform_values do |paths|
      paths.map { |path| (File.basename(path).split('.')[1..] || []).join('.') }
    end

    base_path_exts_map.flat_map do |base_path, exts|
      non_rb_exts = exts.reject { |ext| ext == "rb" }

      raise "Multiple page templates found for #{base_path}: #{non_rb_exts.join(', ')}" if non_rb_exts.size > 1

      from_base_path(base_path, template_extension: non_rb_exts.first) || []
    end
  end

  def page_subclass_under(
    namespaces,
    class_name: "Page",
    root_namespace: config.site.pages_namespace_module,
    parent_class: config.page_base_class
  )
    ns = namespaces.inject(root_namespace) do |ns, namespace|
      ns.const_defined?(namespace, false) ? ns.const_get(namespace, false) :
                                            ns.const_set(namespace, Module.new)
    end

    if ns.const_defined?(class_name, false)
      ns.const_get(class_name, false)
    else
      phantom_page_class = Class.new(parent_class) do
        def self.phantom? = true
      end
      ns.const_set(class_name, phantom_page_class)
    end
  rescue NameError
    nil
  end

  private

  def from_base_path(base_path, template_extension:)
    class_name = base_path.classify
    page_class_defined = config.site.pages_namespace_module.const_defined?(class_name, false) rescue false
    page_class =
      if page_class_defined
        config.site.pages_namespace_module.const_get(class_name, false)
      else
        page_subclass_under(class_name.split("::")[...-1])
      end

    if page_class.respond_to?(:expand_instances_for)
      page_class.expand_instances_for(base_path, template_extension:)
    else
      nil
    end
  end

  def remove_ext(path)
    basename = File.basename(path)
    basename_without_exts = basename.sub(/\..*$/, '')
    dirname = File.dirname(path)
    File.join(*[dirname == "." ? nil : dirname, basename_without_exts].compact)
  end
end
