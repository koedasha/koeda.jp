class Pages::Apps::Slug::Page < Page
  layout :apps

  def before_render
    content_for :app_name, app.name_ja
    content_for :app_image, app.image
  end

  def app = Product.find_by_slug(segments[:slug])
end
