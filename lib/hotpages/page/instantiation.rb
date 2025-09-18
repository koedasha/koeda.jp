module Hotpages::Page::Instantiation
  using Hotpages::Support::StringInflections

  IGNORED_PATH_REGEXP = /\/_[^_]/.freeze

  def all
    all_page_files = Dir.glob(site.pages_path.join("**/*"))
    from_absolute_paths(all_page_files)
  end

  def page_subclass_under(
    namespace,
    preferred_class_name: nil,
    fallback_class_name: "Page",
    phantom_class_name: "Page_",
    root_namespace: site.pages_namespace_module,
    page_base_class: site.page_base_class
  )
    ns = namespace.then do
      break it if it.is_a?(Module)

      namespaces =
        case it
        when String then it.classify.split("::")
        when Array then it.map(&:classify)
        end

      namespaces.inject(root_namespace) do |ns, namespace|
        ns.const_defined?(namespace, false) ? ns.const_get(namespace, false) :
                                              ns.const_set(namespace, Module.new)
      end
    end

    if preferred_class_name && (ns.const_defined?(preferred_class_name, false) rescue false)
      ns.const_get(preferred_class_name, false)
    elsif ns.const_defined?(fallback_class_name, false)
      ns.const_get(fallback_class_name, false)
    else
      if ns.const_defined?(phantom_class_name, false)
        ns.const_get(phantom_class_name, false)
      else
        phantom_page_class = Class.new(page_base_class) do
          def self.phantom? = true
        end
        ns.const_set(phantom_class_name, phantom_page_class)
      end
    end
  rescue NameError
    nil
  end

  private

  def from_absolute_paths(paths)
    base_paths = paths.inject([]) do |result, path|
      next result unless path.start_with?(site.pages_path.to_s)

      base_path = path.sub(site.pages_path.to_s, "").delete_prefix("/")

      next result if base_path =~ IGNORED_PATH_REGEXP

      absolute_path = File.expand_path(path)

      File.file?(absolute_path) ? result << base_path :result
    end

    base_path_exts_map = base_paths.group_by { |path| remove_all_ext(path) }.transform_values do |paths|
      paths.map { |path| (File.basename(path).split(".")[1..] || []).join(".") }
    end

    base_path_exts_map.flat_map do |base_path, exts|
      non_rb_exts = exts.reject { |ext| ext == "rb" }

      raise "Multiple page templates found for #{base_path}: #{non_rb_exts.join(', ')}" if non_rb_exts.size > 1

      from_base_path(base_path, template_file_ext: non_rb_exts.first) || []
    end
  end

  def from_base_path(base_path, template_file_ext:)
    segments = base_path.split("/")
    page_class = page_subclass_under(segments[...-1], preferred_class_name: segments.last.classify)

    if page_class.respond_to?(:expand_instances_for)
      page_class.expand_instances_for(base_path, template_file_ext:)
    else
      nil
    end
  end

  def remove_all_ext(path)
    basename = File.basename(path)
    basename_without_exts = basename.sub(/\..*$/, "")
    dirname = File.dirname(path)
    File.join(*[ dirname == "." ? nil : dirname, basename_without_exts ].compact)
  end
end
