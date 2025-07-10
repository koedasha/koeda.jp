module SiteHelper
  def image_path(image_name)
    File.join("/", config.site.assets_path, "images", image_name)
  end

  def tag(name, **options, &block)
    attributes = options.map { |key, value| "#{key}='#{value}'" }.join(" ")

    if block_given?
      content = @buf.capture(&block)
      "<#{name} #{attributes}>#{content}</#{name}>"
    else
      "<#{name} #{attributes}>"
    end
  end

  def image_tag(image_name, alt: "", **options)
    options[:alt] = alt
    options[:src] = image_path(image_name)
    tag(:img, **options)
  end

  def link_to(url, text = nil, **options, &block)
    options[:href] = url

    if block_given?
      tag(:a, **options, &block)
    else
      tag(:a, **options) { text || url }
    end
  end
end
