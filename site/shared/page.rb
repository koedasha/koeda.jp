class Page < Hotpages::Page
  phantom_page_base_class!

  def header? = true
  def site_name = "Site"
  def site_description = "こえだ舎はアプリと開発サービスを提供しています"
end
