require "digest/sha1"

class Hotpages::Asset
  attr_reader :url

  def initialize(location, url_prefix: Hotpages.config.assets.prefix, directory: nil)
    @location = location
    @url_prefix = url_prefix
    @directory = directory || Hotpages.site.assets_path.to_s
    @external = !!URI(@location).host
    relative_path = !external? && @location.start_with?("./")
    @url = if external?
      @location
    elsif relative_path
      @location.delete_prefix(@directory.to_s)
    else
      url_prefix + @location.delete_prefix(@directory.to_s)
    end
    @abs_path = @external ? nil : File.join(@directory, @location)
  end

  def digested_url
    return url if external?

    "#{url}#{query_separator}v=#{digest}"
  end

  def read_file = File.read(abs_path)

  private

  attr_reader :abs_path

  def external? = @external
  def query_separator = url.include?("?") ? "&" : "?"

  def digest
    @digest ||= begin
      return nil if external?

      Digest::SHA1.hexdigest(read_file)[0, 8]
    end
  end
end
