module Hotpages::Helpers::PageFinding
  def page_exists?(path) = page_finder.find_by_path(path)

  private

  def page_finder
    @page_finder ||= Hotpages::Page::Finder.new(config)
  end
end
