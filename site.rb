require "#{__dir__}/lib/hotpages"
require "tilt"

Tilt.register(Tilt::KramdownTemplate, "md")

class Site < Hotpages::Site
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "ja"
end
