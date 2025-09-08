# TODO: prefixing asset path is required
# css: SiteGenerator#generate_assets, modifying css import part
# js, image: override asset_path helper function
module Hotpages::Extensions::PrefixingPageLinks
  extend Hotpages::Extension

  extension do
    it.configure do |config|
      config.site.add(
        # Url prefix for page URLs when generating static files.
        # When deploying the site to a subdirectory, set this along with `assets.prefix` config.
        page_links_url_prefix: ""
      )
    end
    it.prepend to: Hotpages::Helpers::UrlHelper
  end

  include Hotpages::Helpers::PageHelper

  def link_to(*args, **options, &block)
    url = args.last

    if page_url?(url) && url.start_with?("/")
      options[:href] = File.join(config.site.page_links_url_prefix, url)
    end

    super(*args, **options, &block)
  end
end
