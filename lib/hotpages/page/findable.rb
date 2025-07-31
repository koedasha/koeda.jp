module Hotpages::Page::Findable
  def find_by_path(path)
    finder.find_for(path)
  end

  def exists?(path)
    !!find_by_path(path)
  end

  private

  def finder
    @finder ||= Hotpages::Page::Finder.new(config)
  end
end
