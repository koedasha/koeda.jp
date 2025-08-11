require "#{__dir__}/lib/hotpages"
require "tilt"

Tilt.register(Tilt::KramdownTemplate, "md")

class Site < Hotpages::Site
  config.site.root = File.join(__dir__, "site")
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "ja"
end

Hotpages.setup_site(Site)
