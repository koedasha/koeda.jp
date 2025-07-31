class Pages::Apps::Slug::Page < Page
  layout :apps

  def app = Product.find_by_slug(segments[:slug])
end
