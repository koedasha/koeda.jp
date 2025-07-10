module SiteHelper
  def image_path(image_name)
    File.join("/", config.site.assets_path, "images", image_name)
  end

  def tag(name, **options, &block)
    attributes = attributes_string(options)
    content = block_given? ? capture(&block) : ""
    normalized_name = name.to_s.tr("_", "-")

    "<#{normalized_name} #{attributes}>#{content}</#{name}>"
  end

  def image_tag(image_name, alt: "", **options)
    options[:alt] = alt
    options[:src] = image_path(image_name)
    tag(:img, **options)
  end

  def link_to(url, **options, &block)
    options[:href] = url

    if block_given?
      tag(:a, **options, &block)
    else
      tag(:a, **options) { url }
    end
  end

  def link_to_page(page_path, **options, &block)
    unless Hotpages.config.page_base_class.exists?(page_path)
      raise ArgumentError, "Page not found while generating link with 'link_to_page': #{page_path}"
    end

    link_to(page_path, **options, &block)
  end

  private

  def attributes_string(attributes, key_prefix: "")
    attributes.map do |key, value|
      normalized_key = key.to_s.tr("_", "-")

      if value.is_a?(Hash)
        attributes_string(value, key_prefix: "#{key_prefix}#{normalized_key}-")
      else
        normalized_value = value.is_a?(String) ? value : value.to_s.tr("_", "-")
        "#{key_prefix}#{normalized_key}='#{normalized_value}'"
      end
    end.join(" ")
  end
end
