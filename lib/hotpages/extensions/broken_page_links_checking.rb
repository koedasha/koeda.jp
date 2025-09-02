module Hotpages::Extensions::BrokenPageLinksChecking
  extend Hotpages::Extension

  spec do
    it.prepend to: Hotpages::Helpers::UrlHelper
  end

  include Hotpages::Helpers::PageHelper

  def process_url(url, options = {})
    if options.delete(:check_broken) != false && page_url?(url)
      raise "Broken page link detected: #{url}" if !page_exists?(url)
    end

    super(url, options)
  end
end
