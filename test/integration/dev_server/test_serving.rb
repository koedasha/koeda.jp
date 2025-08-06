require "test_helper"
require "net/http"

class TestServing < Minitest::Test
  @@setup_done = false
  def setup
    return if @@setup_done

    Hotpages.site.generate

    @@port = 12345
    @@server = Hotpages::DevServer.new(site: Hotpages.site, port: @@port, hot_reload: false)
    @@server_thread = Thread.new { @@server.start }
    @@setup_done = true

    sleep 0.1
  end

  Minitest.after_run do
    if defined?(@@server_thread)
      @@server.stop
      @@server_thread.join
      @@server = nil
      sleep 0.1
    end
  end

  def test_serves_all_pages
    Dir.glob(Hotpages.site.dist_path.join("**/*")).each do |file|
      next if File.directory?(file)

      file_path = file.sub(Hotpages.site.dist_path.to_s, "")
      uri = URI("http://localhost:#{@@port}#{file_path}")
      res = Net::HTTP.get_response(uri)
      assert_equal "200", res.code, "Failed for #{file_path}"
      assert_page_content file_path, res.body
    end
  end

  def test_serves_404_page_for_non_existent_page
    uri = URI("http://localhost:#{@@port}/not-exist")
    res = Net::HTTP.get_response(uri)
    assert_equal "404", res.code, "Failed to serve /not-exist"
  end

  def test_serves_without_file_extension
    uri = URI("http://localhost:#{@@port}/posts/1/bar/index")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code, "Failed to serve /posts/1/bar/index"
    assert_page_content "posts/1/bar/index.html", res.body
  end

  def test_serves_index_without_filename
    uri = URI("http://localhost:#{@@port}/posts/1/bar/")
    res = Net::HTTP.get_response(uri)
    assert_equal "200", res.code, "Failed to serve /posts/1/bar/"
    assert_page_content "posts/1/bar/index.html", res.body
  end

  def test_not_serves_txt_without_file_extension
    uri = URI("http://localhost:#{@@port}/robot")
    res = Net::HTTP.get_response(uri)
    assert_equal "404", res.code, "Should not serve /robot.txt without extension"
  end

  private

  def assert_page_content(expected_path, actual_content)
    actual_content = actual_content.force_encoding("UTF-8").encode("UTF-8")
    expected_content = File.read(Hotpages.site.dist_path.join(expected_path.delete_prefix("/")))
    expected_content = expected_content.gsub(/(\S)[?&]v=[a-z0-9]+/) { $1 } # Remove cache buster
    assert_equal expected_content, actual_content, "File content mismatch for #{expected_path}"
  end
end
