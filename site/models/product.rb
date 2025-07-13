class Product
  class << self
    def all
      @products ||= [
        new(
          slug: "elapsed-times",
          name: "時間計測タイマー",
          image: "ph.svg",
          description: "メモ機能と通知機能のついた時間計測タイマー"
        ),
        # new(slug: "two", name: "Product 2", image: "product2.jpg", description: "Description for Product 2"),
        # new(slug: "three", name: "Product 3", image: "product3.jpg", description: "Description for Product 3")
      ]
    end

    def page_names = all.map { _1.slug }

    def find_by_slug(slug)
      all.find { |product| product.slug == slug }
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
