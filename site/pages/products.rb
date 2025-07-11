class Pages::Products < Page
  def body
    <<~HTML
      <h1>Products</h1>
      <p>Here are some of our products:</p>
      <ul>
        <% products.each do |product| -%>
          <li><%= product -%></li>
        <% end %>
      </ul>
    HTML
  end

  private

  def products = ["Product 1", "Product 2", "Product 3"]
end
