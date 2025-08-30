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
      [ text_or_url, url_or_nil ]
    else
      [ nil, text_or_url ]
    end

    if page_url?(url)
      if check_broken && !page_exists?(url)
        raise "Broken page link detected: #{url}"
      end

      url = prefix_page_url(url)
      
      # Add data attributes for scroll-to-top behavior on internal page navigation
      options[:"data-turbo-action"] ||= "advance"
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

  def prefix_page_url(url)
    return url unless url.start_with?("/")

    if Hotpages.site.generating?
      url = File.join(config.site.generator.links_url_prefix, url)
    end

    url
  end
end
