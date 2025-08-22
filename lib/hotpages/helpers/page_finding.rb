module Hotpages::Helpers::PageFinding
  def page_exists?(path)
    if path.start_with?(".")
      directory = Pathname.new(File.dirname(expanded_base_path))
      path = directory.join(path).cleanpath.to_s
    end
    page_finder.find(path)
  end

  private

  def page_finder
    @page_finder ||= Hotpages::Page::Finder.new(site)
  end
end
