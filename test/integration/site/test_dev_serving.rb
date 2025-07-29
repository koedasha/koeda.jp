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
    Hotpages.site.generate
    @server_thread = Thread.new { Hotpages.dev_server.start }
    sleep 0.1
  end

  def teardown
    Hotpages.dev_server.stop
    @server_thread.join
    Hotpages.site.teardown
    sleep 0.1
  end

  def test_serves_all_pages
    Dir.glob(File.join(__dir__, "../../dist/expected/**/*")).each do |file|
      next if File.directory?(file)

      relative_path = file.sub(File.join(__dir__, "../../dist/expected"), "")
      uri = URI("http://localhost:#{TEST_PORT}#{relative_path}")
      res = Net::HTTP.get_response(uri)
      assert_equal "200", res.code, "Failed for #{relative_path}"
      assert_page_content relative_path, res.body
    end

    # HTML should be served without file extension
    uri = URI("http://localhost:#{TEST_PORT}/posts/1/bar/index")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code, "Failed to serve /posts/1/bar/index"
    assert_page_content "posts/1/bar/index.html", res.body

    # index.html should be served without file name
    uri = URI("http://localhost:#{TEST_PORT}/posts/1/bar/")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code, "Failed to serve /posts/1/bar/"
    assert_page_content "posts/1/bar/index.html", res.body

    # TXT should not be served without file extension
    uri = URI("http://localhost:#{TEST_PORT}/robot")
    res = Net::HTTP.get_response(uri)
    assert_equal "404", res.code, "Should not serve /robot.txt without extension"
  end

  private

  def assert_page_content(expected_path, actual_content)
    actual_content = actual_content.force_encoding("UTF-8").encode("UTF-8")
    expected_content = File.read(File.join(__dir__, "../../dist/expected", expected_path))
    assert_equal expected_content, actual_content, "File content mismatch for #{expected_path}"
  end
end
