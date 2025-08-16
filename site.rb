require "#{__dir__}/lib/hotpages"

class Site < Hotpages::Site
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "ja"
end

Hotpages.setup_site(Site) do |site|
  Tilt.register(Tilt::KramdownTemplate, "md")
  site.phantom_page_base_class = Page
end
