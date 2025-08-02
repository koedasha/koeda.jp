require "test_helper"
require "digest"

class TestSiteGeneration < Minitest::Test
  def setup
    Hotpages.site.generate
  end

  def test_site_generation
    expected_dist = File.join(__dir__, "../../dist/expected")
    actual_dist = Hotpages.site.config.site.dist_absolute_path

    expected_files = Dir.glob("#{expected_dist}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
    actual_files = Dir.glob("#{actual_dist}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }

    expected_relative_files = expected_files.map { |f| f.sub(/^#{Regexp.escape(expected_dist)}\//, '') }.sort
    actual_relative_files = actual_files.map { |f| f.sub(/^#{Regexp.escape(actual_dist)}\//, '') }.sort

    assert_equal expected_relative_files, actual_relative_files

    # Assert file contents
    expected_relative_files.each do |rel_path|
      expected_file = File.join(expected_dist, rel_path)
      actual_file = File.join(actual_dist, rel_path)

      expected_hash = Digest::SHA256.file(expected_file).hexdigest
      actual_hash = Digest::SHA256.file(actual_file).hexdigest

      assert_equal expected_hash, actual_hash, "File content not match: #{rel_path}"
    end
  end
end
