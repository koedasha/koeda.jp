class Product
  extend Sluggable

  class << self
    def all
      @products ||= [
        new(slug: "one", name: "Product 1", image: "product1.jpg", description: "Description for Product 1"),
        new(slug: "two", name: "Product 2", image: "product2.jpg", description: "Description for Product 2"),
        new(slug: "three", name: "Product 3", image: "product3.jpg", description: "Description for Product 3")
      ]
    end
  end

  attr_reader :slug, :name, :image, :description

  def initialize(slug:, name:, image:, description:)
    @slug = slug
    @name = name
    @image = image
    @description = description
  end
end
