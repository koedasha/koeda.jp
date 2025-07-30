# App
Product = Data.define(:slug, :image, :name_ja, :description_ja) do
  class << self
    def all
      @products ||= [
        new(
          slug: "elapsed-times",
          image: "ph.svg",
          name_ja: "時間計測タイマー",
          description_ja: "メモ機能と通知機能のついた時間計測タイマーです。日常生活のさまざまなシーンで活用いただけます。"
        )
      ]
    end

    def segment_names = all.map { _1.slug }

    def find_by_slug(slug)
      all.find { |product| product.slug == slug }
    end
  end
end
