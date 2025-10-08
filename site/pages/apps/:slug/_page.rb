layout :apps

before_render :set_contents

def app = Product.find_by_slug(segments[:slug])

private

def set_contents
  content_for :title, app.name(locale:)
  content_for :app_name, app.name(locale:)
  content_for :app_image, app.image
end
