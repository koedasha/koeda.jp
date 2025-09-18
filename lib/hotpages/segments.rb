module Hotpages::Segments
  using Hotpages::Support::StringInflections

  IGNORED_PATH_REGEXP = /\/_[^_]/.freeze

  private

  def page_subclass_under(
    namespace,
    class_name: nil,
    fallback_class_name: "Page",
    phantom_class_name: "Page_"
  )
    (class_name && segment_constant_under(namespace, class_name)) ||
      segment_constant_under(namespace, fallback_class_name) ||
      segment_constant_under(namespace, phantom_class_name) ||
      new_phantom_page_class_under(namespace, phantom_class_name)
  rescue NameError
    nil
  end

  def segment_constant_under(segment, child_name)
    segment = constantize_namespace(segment)

    if (segment.const_defined?(child_name, false) rescue false)
      segment.const_get(child_name, false)
    else
      nil
    end
    # rescue Zeitwerk::NameError
    # TODO: Handle class-less page/directories
    # TODO: ファイルシステムからページかディレクトリか判別可能
    # base_path = "TODO"
    # Hotpages::Page.page_subclass_under(name.underscore, class_name: child_name)
  end

  def constantize_namespace(namespace, root_namespace: Hotpages.site.pages_namespace_module)
    return namespace if namespace.is_a?(Module)

    namespaces =
      case namespace
      when String then namespace.classify.split("::")
      when Array then namespace.map(&:classify)
      end

    namespaces.inject(root_namespace) do |ns, namespace|
      ns.const_defined?(namespace, false) ? ns.const_get(namespace, false) :
                                            ns.const_set(namespace, Module.new)
    end
  end

  def new_phantom_page_class_under(namespace, class_name, page_base_class: Hotpages.site.page_base_class)
    phantom_page_class = Class.new(page_base_class) do
      def self.phantom? = true
    end
    ns = constantize_namespace(namespace)

    ns.const_set(class_name, phantom_page_class)
  end
end
