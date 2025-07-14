require "test_helper"
require "net/http"

class TestSiteDevServing < Minitest::Test
  TEST_PORT = 12345

  class TestSite < Hotpages::Site
    config.site.root = File.join(__dir__, "../../test_site")
    config.site.dist_path = "../dist/actual"
    config.dev_server.port = TEST_PORT
  end

  def setup
    Hotpages.setup_site(TestSite)
    Hotpages.config.page_base_class = Page
    @server_thread = Thread.new { Hotpages.dev_server.start }
    sleep 0.1
  end

  def teardown
    Hotpages.dev_server.stop
    @server_thread.join
    Hotpages.site.teardown
    sleep 0.1
  end

  def test_site_dev_serving
    uri = URI("http://localhost:#{TEST_PORT}/")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code
    assert_match %r{<title>My Site</title>}, res.body

    uri = URI("http://localhost:#{TEST_PORT}/products")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code
    assert_match %r{<h1>Products</h1>}, res.body

    uri = URI("http://localhost:#{TEST_PORT}/products/")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code
    assert_match %r{<h1>Products</h1>}, res.body

    uri = URI("http://localhost:#{TEST_PORT}/products/one")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code
    assert_match %r{Product 1}, res.body

    uri = URI("http://localhost:#{TEST_PORT}/assets/site.css")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code
    assert_match %r{body \{}, res.body
  end
end
