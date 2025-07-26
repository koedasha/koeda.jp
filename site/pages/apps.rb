class Pages::Apps < Page
  def products = Product.all
end
