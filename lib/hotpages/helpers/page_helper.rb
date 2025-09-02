module Hotpages::Helpers::PageHelper
  def page_exists?(path)
    unless path.start_with?("/")
      directory = Pathname.new(File.dirname(expanded_base_path))
      path = directory.join(path).cleanpath.to_s
    end
    page_finder.find(path)
  end

  def page_url?(url)
    uri = URI(url)

    return false if !!uri.host # external URL
    return false if url.start_with?("mailto:") # mailto link

    true
  end

  private

  def page_finder
    @page_finder ||= Hotpages::PageFinder.new(site)
  end
end
