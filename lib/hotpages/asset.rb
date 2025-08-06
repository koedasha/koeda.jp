require "digest/sha1"

class Hotpages::Asset
  attr_reader :location

  def initialize(location, directory: Hotpages.site.root)
    @location = location
    @external = location.start_with?("http://", "https://")
    @location = @external ? location : location.delete_prefix(directory)
    @absolute_location = @external ? location : File.join(directory, @location)
  end

  def digested_location
    return location if external?

    "#{location}#{query_separator}v=#{digest}"
  end

  private

  attr_reader :absolute_location

  def external? = @external
  def query_separator = location.include?("?") ? "&" : "?"

  def digest
    @digest ||= begin
      return nil if external?

      Digest::SHA1.hexdigest(File.read(absolute_location))[0, 8]
    end
  end
end
