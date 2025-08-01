module Sluggable
  def page_names = all.map { _1.slug }
  def find_by_slug(slug)
    all.find { _1.slug == slug }
  end
end
