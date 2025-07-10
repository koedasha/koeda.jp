class Pages::Index < Koeda::Page
  def products = Product.all
end
