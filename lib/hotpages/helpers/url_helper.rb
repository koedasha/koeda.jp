require "uri"

module Hotpages::Helpers::UrlHelper
  def link_to(
    text_or_url, url_or_nil = nil,
    **options,
    &block
  )
    text, url = if url_or_nil
      [ text_or_url, url_or_nil ]
    else
      [ nil, text_or_url ]
    end

    options[:href] ||= process_url(url, options)

    if block_given?
      tag.a(options, &block)
    else
      tag.a(options) { concat(text || url) }
    end
  end

  # For override by extensions
  def process_url(url, _options) = url
end
