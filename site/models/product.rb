# App
Product = Data.define(
  :slug, :image, :ios_url, :inquiry_form_url,
  :name_ja, :name_en, :copy_ja, :desc_ja, :desc_en,
  :store_url_jp,
  :screenshot_ja, :screenshot_en,
  :data
) do
  class << self
    def all
      @products ||= [
        new(
          slug: "elapsed-times",
          image: "images/elapsed-times/app-icon.png",
          ios_url: "https://apps.apple.com/app/elapsedtimes/id6752881453",
          inquiry_form_url: "https://docs.google.com/forms/d/e/1FAIpQLSegCXkXlyD6rMpO-3c738bcnq-TL9ozYkS5TFehvHrGAWntCw/viewform?usp=header",
          name_ja: "時間計測タイマー",
          name_en: "ElapsedTimes",
          copy_ja: "ワンタップで計測開始。日常生活の中で時間を計測したいときに役立つタイマーアプリ。",
          desc_ja: <<~MD,
            時間を測りたい、そう思ったらワンタップで計測開始。

            通知設定により複数のタイマーを同時進行。便利なメモ機能や履歴機能も。

            機能概要
            ======

            * 複数のタイマー作成（無料版では4個まで。有料版購入で無制限）

            * タイマーの概要を一目で把握できる詳細画面

            * タイマーを並び替えやグループで整理

            * タイマーごとに複数の通知を設定可能（無料版では1タイマーにつき1個まで。有料版購入で12個まで）

            * メモ機能

            * 履歴機能（過去の計測を999件まで保存。CSVでエクスポート可能）

            * ダークモード対応
          MD
          desc_en: <<~MD,
            Measure time in one tap.

            Multiple timers, seamless notifications, and a simple way to record notes and history.

            Features overview
            ==============

            * Create multiple timers (up to 4 in the free version. Unlimited with the purchase of the paid version)

            * A detailed screen where you can get an overview of the timer at a glance

            * Reorder timers and organize them in groups

            * Multiple notifications can be set for each timer (up to one per timer in the free version. Up to 12 when purchasing the paid version)

            * Record notes

            * Tracking history (up to 999 past measurements can be saved, exportable as CSV)

            * Compatible with dark mode
          MD
          store_url_jp: "https://apps.apple.com/jp/app/twitter/id333903271",
          screenshot_ja: "images/elapsed-times/main.ja.png",
          screenshot_en: "images/elapsed-times/main.en.png",
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

  def screenshot_path(locale:)
    case locale
    when "ja" then screenshot_ja
    when "en" then screenshot_en
    end
  end

  def desc(locale:)
    case locale
    when "ja" then desc_ja
    when "en" then desc_en
    end
  end

  def terms_path(locale:)
    "data/apps/#{slug.gsub("-", "_")}/terms_#{locale}.md"
  end

  def privacy_path(locale:)
    "data/apps/#{slug.gsub("-", "_")}/privacy_#{locale}.md"
  end
end
