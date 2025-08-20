require "#{__dir__}/lib/hotpages"
require "tilt"

Tilt.register(Tilt::KramdownTemplate, "md")

# TODO: loader setup for site specific extensions
Hotpages.loader.push_dir("#{__dir__}/site/extensions")
Hotpages.reload
Hotpages.extensions << TemplatePathAnnotation
Hotpages.extensions << LucideIcons

class Site < Hotpages::Site
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "ja"
end
