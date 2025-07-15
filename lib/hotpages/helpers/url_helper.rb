module Hotpages::Helpers::UrlHelper
  def link_to(text_or_url, url_or_nil = nil, **options, &block)
    text, url = if url_or_nil
                  [text_or_url, url_or_nil]
                else
                  [nil, text_or_url]
                end

    if block_given?
      tag.a options.merge(href: url), &block
    else
      tag.a options { text || url }
    end
  end

  def link_to_page(page_path, **options, &block)
    unless config.page_base_class.exists?(page_path)
      raise "Page not found while generating link with 'link_to_page': #{page_path}"
    end

    link_to(page_path, **options, &block)
  end
end
