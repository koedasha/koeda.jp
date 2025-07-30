class Pages::Apps < Page
  def apps = Product.all
end
