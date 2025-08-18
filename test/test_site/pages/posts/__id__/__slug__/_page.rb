class Pages::Posts::Id::Slug::Page < Page
  before_render :set_contents

  private

  def set_contents
    content_for :post_title, "Alice in Wonderland(#{segments[:id]}-#{segments[:slug]})"
  end
end
