# App
Product = Data.define(
  :slug, :image, :ios_url,
  :name_ja, :name_en, :copy_ja, :desc_ja, :store_url_jp, :screenshot_ja,
  :data
) do
  class << self
    def all
      @products ||= [
        new(
          slug: "elapsed-times",
          image: "images/elapsed-times/app-icon.png",
          ios_url: nil,
          name_ja: "時間計測タイマー",
          name_en: "ElapsedTimes",
          copy_ja: "ワンタップで計測開始。日常生活の中で時間を計測したいときに役立つタイマーアプリ。",
          desc_ja: <<~MD,
          「あれからどれくらいたったかな？」

          日常生活の中でそんなふうに思う瞬間はないでしょうか。

          時間計測タイマーは、時間を測るという目的に特化したアプリです。

          グループにまとめた複数のタイマーでの同時計測やメモ機能、充実した通知機能により、さまざまな時間を測りたいシーンでお使いいただけます。
          MD
          store_url_jp: "https://apps.apple.com/jp/app/twitter/id333903271",
          screenshot_ja: "images/elapsed-times/promo-1.ja.webp",
          data: { product_ids: [ "ElapsedTimes.Plus" ] }
        )
      ]
    end

    def segment_names = all.map { it.slug }

    def find_by_slug(slug)
      all.find { |product| product.slug == slug }
    end
  end

  def name(locale:)
    case locale
    when "ja" then name_ja
    when "en" then name_en
    end
  end

  def terms_path(locale:)
    "data/apps/#{slug.gsub("-", "_")}/terms_#{locale}.md"
  end

  def privacy_path(locale:)
    "data/apps/#{slug.gsub("-", "_")}/privacy_#{locale}.md"
  end
end
