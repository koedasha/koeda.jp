require "minitest/autorun"
require "hotpages"

class TestSite < Hotpages::Site
  config.site.root = File.join(__dir__, "test_site")
  config.site.dist_path = "../dist/actual"
  config.dev_server.port = 12345
end

Hotpages.setup_site(TestSite)
Hotpages.config.page_base_class = ::Page

Minitest.after_run do
  Hotpages.teardown
end
