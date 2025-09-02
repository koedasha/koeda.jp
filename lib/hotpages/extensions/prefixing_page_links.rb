module Hotpages::Extensions::PrefixingPageLinks
  extend Hotpages::Extension

  prepending to: "Hotpages::Helpers::UrlHelper"

  include Hotpages::Helpers::PageHelper

  private

  def process_url(url, **options)
    url = super
    return url unless url.start_with?("/")

    File.join(config.site.generator.links_url_prefix, url)
  end
end
