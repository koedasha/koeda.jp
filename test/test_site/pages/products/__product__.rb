class Pages::Products::Product < Page
  class << self
    def segment_names = Product.page_names
  end

  def product = Product.find_by_slug(name)
end
