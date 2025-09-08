module Hotpages::Extensions::BrokenPageLinksChecking
  extend Hotpages::Extension

  extension do
    it.prepend to: Hotpages::Helpers::UrlHelper
  end

  include Hotpages::Helpers::PageHelper

  def link_to(*args, **options, &block)
    url = args.last

    if options.delete(:check_broken) != false && page_url?(url)
      raise "Broken page link detected: #{url}" if !page_exists?(url)
    end

    super(*args, **options, &block)
  end
end
