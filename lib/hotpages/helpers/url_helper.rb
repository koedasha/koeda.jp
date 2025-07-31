require "uri"

module Hotpages::Helpers::UrlHelper
  def link_to(text_or_url, url_or_nil = nil, **options, &block)
    text, url = if url_or_nil
                  [text_or_url, url_or_nil]
                else
                  [nil, text_or_url]
                end

    options[:href] ||= url

    if block_given?
      tag.a(options, &block)
    else
      tag.a(options) { concat(text || url) }
    end
  end

  # TODO: generaterで行うようにする。link_toの使用で相対パスが渡された時とする
  # def link_to_page(page_path, **options, &block)
  #   unless config.page_base_class.exists?(page_path)
  #     raise "Page not found while generating link with 'link_to_page': #{page_path}"
  #   end

  #   link_to(page_path, **options, &block)
  # end

  private

  def compose_url(url, **query_params)
    uri = URI(url)
    uri.query = URI.encode_www_form(query_params) if query_params.any?
    uri.to_s
  end
end
