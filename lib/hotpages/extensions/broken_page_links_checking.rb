module Hotpages::Extensions::BrokenPageLinksChecking
  extend Hotpages::Extension

  prepending to: "Hotpages::Helpers::UrlHelper"

  include Hotpages::Helpers::PageHelper

  private

  def process_url(url, **options)
    url = super

    if options[:check_broken] && !page_url?(url)
      raise "Broken page link detected: #{url}" if !page_exists?(url)
    end

    url
  end
end
