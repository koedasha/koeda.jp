require "hotpages"
require "kramdown"

# TODO: loader setup for site specific extensions
Hotpages.loader.push_dir("#{__dir__}/site/extensions")
Hotpages.reload
Hotpages.extensions << LucideIcons

class Site < Hotpages::Site
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "ja"
  config.site.i18n.unlocalized_path_patterns << /data.json\z/
end
