require "test_helper"
require "digest"

class TestGeneration < Minitest::Test
  def setup
    pid = fork do
      Hotpages.extensions += [
        Hotpages::Extensions::AssetCacheBusting,
        Hotpages::Extensions::BrokenPageLinksChecking,
        Hotpages::Extensions::PrefixingPageLinks
      ]
      Hotpages.reload
      Hotpages.site.reload
      Hotpages::SiteGenerator.new(site: Hotpages.site).generate
    end

    Process.wait(pid)
  end

  def test_site_generation
    expected_dist = File.join(__dir__, "../../dist/expected")
    actual_dist = Hotpages.site.dist_path.to_s

    expected_files = Dir.glob("#{expected_dist}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
    actual_files = Dir.glob("#{actual_dist}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }

    expected_relative_files = expected_files.map { |f| f.sub(/^#{Regexp.escape(expected_dist)}\//, "") }.sort
    actual_relative_files = actual_files.map { |f| f.sub(/^#{Regexp.escape(actual_dist)}\//, "") }.sort

    assert_equal expected_relative_files, actual_relative_files

    # Assert file contents
    expected_relative_files.each do |rel_path|
      expected_file = File.join(expected_dist, rel_path)
      actual_file = File.join(actual_dist, rel_path)

      expected_content = File.read(expected_file)
      actual_content = File.read(actual_file)

      assert_equal expected_content, actual_content, "File content not match: #{rel_path}"
    end
  end
end
