class Pages::Index < Page
  def products = Product.all
end
