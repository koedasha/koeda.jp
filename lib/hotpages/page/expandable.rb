module Hotpages::Page::Expandable
  using Hotpages::Refinements::String

  EXPANDABLE_SEGMENT_REGEXP = /\A__(.+)__/.freeze

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def segment_names = nil

    def expand_instances_for(base_path, template_extension:)
      namespaces = self.name.split("::")
      namespaces.shift # Remove the first `Pages` namespace

      current_namespace = site.pages_namespace_module
      segment_name_values = namespaces.map do |namespace|
        current_namespace = current_namespace.const_get(namespace, false)

        next nil unless current_namespace.respond_to?(:segment_names)

        names = current_namespace.segment_names

        next nil if names.nil?

        [ namespace.underscore.to_sym, names ]
      end.compact.to_h

      # Not expanded
      return [ new(base_path:, template_extension:) ] if segment_name_values.empty?

      segment_keys = segment_name_values.keys
      segment_values_product = segment_name_values.values.then do |values|
        values.first.product(*values[1..])
      end

      segment_values_product.map do |segment_values|
        segments = segment_keys.zip(segment_values).to_h
        name = segment_names.nil? ? nil : segment_values.last
        new(base_path:, segments:, name:, template_extension:)
      end
    end
  end

  def expanded_base_path
    expanded_segments = base_path.split("/").map do |original_segment|
      match = EXPANDABLE_SEGMENT_REGEXP.match(original_segment)

      next original_segment unless match

      segment_key = match[1].to_sym
      segment_value = segments[segment_key] ||
        raise("Segment `#{segment_key}` is not defined in segments: #{segments.inspect}")

      original_segment.sub(EXPANDABLE_SEGMENT_REGEXP, segment_value.to_s)
    end

    File.join(*expanded_segments)
  end

  def expanded_base_path_with_extension
    ext = if template_extension.nil?
      "html"
    else
      template_extension.split(".").first
    end
    [ expanded_base_path, ext ].compact.join(".")
  end
end
