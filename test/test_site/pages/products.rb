class Pages::Products < Page
  def body
    <<~HTML
      <h1>Products</h1>
      <p>Here are some of our products:</p>
      <ul>
        <% products.each do |product| -%>
          <li><%= product.name -%></li>
        <% end %>
      </ul>
    HTML
  end

  private

  def products = Product.all
end
