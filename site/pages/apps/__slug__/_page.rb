class Pages::Apps::Slug::Page < Page
  layout :apps

  def product = Product.find_by_slug(segments[:slug])
end
