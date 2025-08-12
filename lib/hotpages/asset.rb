require "digest/sha1"

class Hotpages::Asset
  attr_reader :url

  def initialize(location, url_prefix: Hotpages.config.assets.prefix, directory: nil)
    directory = directory || Hotpages.site.assets_path.to_s
    @external = location.start_with?("http://", "https://")
    @force_relative = !@external && location.start_with?(".")
    @url = if external?
      location
    elsif force_relative?
      location.delete_prefix(directory.to_s)
    else
      url_prefix + location.delete_prefix(directory.to_s)
    end
    @absolute_location = @external ? location : File.join(directory, location)
  end

  def digested_url
    return url if external?

    "#{url}#{query_separator}v=#{digest}"
  end

  private

  attr_reader :absolute_location

  def external? = @external
  def force_relative? = @force_relative
  def query_separator = url.include?("?") ? "&" : "?"

  def digest
    @digest ||= begin
      return nil if external?

      Digest::SHA1.hexdigest(File.read(absolute_location))[0, 8]
    end
  end
end
