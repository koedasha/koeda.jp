# App
Product = Data.define(
  :slug, :image,
  :name_ja, :copy_ja, :desc_ja, :store_url_jp, :screenshot_ja
) do
  class << self
    def all
      @products ||= [
        new(
          slug: "elapsed-times",
          image: "elapsed-times.png",
          name_ja: "時間計測タイマー",
          copy_ja: "「あれからどれくらいたったかな？」日常生活の中で時間を計測したいときに役立つタイマーアプリ。",
          desc_ja: <<~MD,
          「あれからどれくらいたったかな？」

          日常生活の中でそんなふうに思う瞬間はないでしょうか。

        時間計測タイマーは、時間を測るという目的に特化したアプリです。

          グループにまとめた複数のタイマーでの同時計測やメモ機能、充実した通知機能により、さまざまな時間を測りたいシーンでお使いいただけます。
          MD
          store_url_jp: "https://apps.apple.com/jp/app/twitter/id333903271",
          screenshot_ja: "elapsed-times-screenshot-ja.png"
        )
      ]
    end

    def segment_names = all.map { it.slug }

    def find_by_slug(slug)
      all.find { |product| product.slug == slug }
    end
  end
end
