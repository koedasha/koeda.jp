require "#{__dir__}/../lib/hotpages"

class Site < Hotpages::Site
  config.site.root = __dir__
end

Hotpages.setup_site(Site)
Hotpages.config.page_base_class = Page
