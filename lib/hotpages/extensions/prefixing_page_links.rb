module Hotpages::Extensions::PrefixingPageLinks
  extend Hotpages::Extension

  spec do
    it.configure do |config|
      config.site.add(
        # Url prefix for page URLs when generating static files.
        # Set this when deploying the site to a subdirectory.
        page_links_url_prefix: ""
      )
    end
    it.prepend to: Hotpages::Helpers::UrlHelper
  end

  include Hotpages::Helpers::PageHelper

  def process_url(url, _options = {})
    url = super
    return url unless page_url?(url) && url.start_with?("/")

    File.join(config.site.page_links_url_prefix, url)
  end
end
