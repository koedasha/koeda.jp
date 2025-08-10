require "#{__dir__}/lib/hotpages"

class Site < Hotpages::Site
  config.page_base_class_name = "Page"
  config.site.root = File.join(__dir__, "site")
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "ja"
end

Hotpages.setup_site(Site)
