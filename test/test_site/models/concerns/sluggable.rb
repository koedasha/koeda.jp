module Sluggable
  def page_names = all.map { it.slug }
  def find_by_slug(slug)
    all.find { it.slug == slug }
  end
end
