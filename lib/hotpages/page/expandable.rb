module Hotpages::Page::Expandable
  using Hotpages::Support::StringInflections

  EXPANDABLE_PATH_COMPONENT_REGEXP = Hotpages::Page::EXPANDABLE_NAME_REGEXP

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def expand_instances_for(base_path, template_file_ext:)
      path_components = base_path.split("/")
      current_path = site.pages_path

      segment_names_by_key = path_components.each_with_object({}).with_index do |(path_component, result), index|
        current_path = current_path.join(path_component)
        expandable_const = if index == path_components.size - 1
          site.page_base_class.subclass_at_path(current_path)
        else
          Hotpages::Directory.subclass_at_path(current_path)
        end

        next unless expandable_const && expandable_const.segment_names

        segment_key = path_component.match(EXPANDABLE_PATH_COMPONENT_REGEXP)[1].to_sym

        result[segment_key] = expandable_const.segment_names
      end

      # Not expanded
      return [ new(base_path:, template_file_ext:) ] if segment_names_by_key.empty?

      segment_keys = segment_names_by_key.keys
      segment_values_product = segment_names_by_key.values.then do |values|
        values.first.product(*values[1..])
      end

      segment_values_product.map do |segment_values|
        segments = segment_keys.zip(segment_values).to_h
        name = segment_names.nil? ? nil : segment_values.last

        new(base_path:, segments:, name:, template_file_ext:)
      end
    end
  end

  def expanded_base_path
    expanded_segments = base_path.split("/").map do |path_component|
      match = EXPANDABLE_PATH_COMPONENT_REGEXP.match(path_component)

      next path_component unless match

      segment_key = match[1].to_sym
      segment_value = segments[segment_key] ||
        raise("Segment `#{segment_key}` is not present in segments: #{segments.inspect}")

      path_component.sub(EXPANDABLE_PATH_COMPONENT_REGEXP, segment_value.to_s)
    end

    File.join(*expanded_segments)
  end

  def expanded_url(omit_html_ext: true, omit_index: true)
    ext = if template_file_ext.nil?
      "html"
    else
      template_file_ext.split(".").first
    end

    raise "Unsupported file type: `#{ext}`" if ext && !config.page_file_types.include?(ext)

    url = [ expanded_base_path, ext ].compact.join(".")

    url = url.sub(/index\.html?\z/, "") \
      if omit_index && (url =~ /\Aindex\.html?\z/ || url =~ /\/index\.html?\z/)
    url = url.delete_suffix(".html").delete_suffix(".htm") if omit_html_ext

    url
  end
end
