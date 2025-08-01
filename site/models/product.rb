# App
Product = Data.define(:slug, :image, :name_ja, :copy_ja) do
  class << self
    def all
      @products ||= [
        new(
          slug: "elapsed-times",
          image: "elapsed-times.png",
          name_ja: "時間計測タイマー",
          copy_ja: "「あれからどれくらいたったかな？」日常生活の中で時間を計測したいときに役立つタイマーアプリ。"
        )
      ]
    end

    def segment_names = all.map { _1.slug }

    def find_by_slug(slug)
      all.find { |product| product.slug == slug }
    end
  end
end
