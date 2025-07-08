class Pages::Products
  include Hotpages::Page

  def render
    <<~HTML
      <h1>Products</h1>
      <p>Here are some of our products:</p>
      <ul>
        <li>Product 1</li>
        <li>Product 2</li>
        <li>Product 3</li>
      </ul>
    HTML
  end
end
