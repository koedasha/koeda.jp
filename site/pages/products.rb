class Pages::Products
  include Hotpages::Page

  def body
    <<~ERB
      <h1>Products</h1>
      <p>Here are some of our products:</p>
      <ul>
        <% products.each do |product| -%>
          <li><%= product -%></li>
        <% end %>
      </ul>
    ERB
  end

  private

  def products = ["Product 1", "Product 2", "Product 3"]
end
