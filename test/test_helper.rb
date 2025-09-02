require "bundler/setup"
require "minitest/autorun"
require "#{__dir__}/../lib/hotpages"

class TestSite < Hotpages::Site
  config.site.root = Pathname.new(__dir__).join("test_site")
  config.site.dist_path = "../dist/actual"
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "en"
end

Minitest.after_run do
  Hotpages.teardown
end
