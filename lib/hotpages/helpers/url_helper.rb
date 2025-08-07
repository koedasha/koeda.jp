require "uri"

module Hotpages::Helpers::UrlHelper
  include Hotpages::Helpers::PageFinding

  def link_to(
    text_or_url, url_or_nil = nil,
    check_broken: Hotpages.site.generating?,
    **options,
    &block
  )
    text, url = if url_or_nil
                  [text_or_url, url_or_nil]
                else
                  [nil, text_or_url]
                end

    if check_broken
      if page_url?(url) && !page_exists?(url)
        raise "page is not found: #{url}"
      end
    end

    options[:href] ||= url

    if block_given?
      tag.a(options, &block)
    else
      tag.a(options) { concat(text || url) }
    end
  end

  private

  def page_url?(url)
    uri = URI(url)

    return false if !!uri.host # external URL
    return false if url.start_with?("mailto:") # mailto link

    true
  end
end
