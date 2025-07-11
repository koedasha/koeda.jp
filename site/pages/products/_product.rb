class Pages::Products::Product < Page
  class << self
    def expanded_ids = Product.ids
  end

  def product = Product.find_by_slug(id)
end
