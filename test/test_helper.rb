require "minitest/autorun"
require "#{__dir__}/../lib/hotpages"

class TestSite < Hotpages::Site
  config.site.root = File.join(__dir__, "test_site")
  config.site.dist_dir = "../dist/actual"
  config.site.i18n.locales = %w[ ja en ]
  config.site.i18n.default_locale = "en"
end

Hotpages.setup_site(TestSite)

# Page class is accessible only after site loader setup
Hotpages.config.page_base_class = ::Page

Minitest.after_run do
  Hotpages.teardown
end
