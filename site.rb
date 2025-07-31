require "#{__dir__}/lib/hotpages"

class Site < Hotpages::Site
  config.site.root = File.join(__dir__, "site")
end

Hotpages.setup_site(Site)
Hotpages.config.page_base_class = Page
