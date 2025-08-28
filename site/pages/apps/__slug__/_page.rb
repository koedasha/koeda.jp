class Pages::Apps::Slug::Page < Page
  layout :apps

  before_render :set_contents

  def app = Product.find_by_slug(segments[:slug])

  private

  def set_contents
    # TDOO: Localize
    content_for :title, app.name_ja
    content_for :app_name, app.name_ja
    content_for :app_image, app.image
  end
end
