require "uri"

module Hotpages::Helpers::UrlHelper
  def link_to(
    body = nil, url = nil,
    **options,
    &block
  )
    url = body if url.nil?

    options[:href] ||= url

    if block_given?
      tag.a(options, &block)
    else
      tag.a(options) { concat(body || options[:href]) }
    end
  end
end
