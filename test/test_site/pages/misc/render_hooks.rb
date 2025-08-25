class Pages::Misc::RenderHooks < Page
  around_render do |page, block|
    @li1 = "around render 1"
    block.call
    @li2 = "around render 2 (This should not be rendered)"
  end

  before_render :before

  def body
    <<~HTML
    <ul>
      <li><%= @li1 %></li>
      <li><%= @li2 %></li>
      <li><%= @li3 %></li>
    </ul>
    HTML
  end

  private

  def before
    @li3 = "before render 1"
  end
end
