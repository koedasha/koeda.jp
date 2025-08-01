class Pages::Posts::Id::Slug::Page < Page
  def before_render
    content_for :post_title, "Alice in Wonderland(#{segments[:id]}-#{segments[:slug]})"
  end
end
