class Pages::Products::Slug < SitePage
  class << self
    def expanded_names = Product.page_names
  end

  def product = Product.find_by_slug(name)
end
