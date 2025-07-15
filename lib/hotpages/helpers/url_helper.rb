module Hotpages::Helpers::UrlHelper
  def link_to(url, **options, &block)
    options[:href] = url

    if block_given?
      tag.a options, &block
    else
      tag.a options { url }
    end
  end

  def link_to_page(page_path, **options, &block)
    unless config.page_base_class.exists?(page_path)
      raise ArgumentError, "Page not found while generating link with 'link_to_page': #{page_path}"
    end

    link_to(page_path, **options, &block)
  end
end
