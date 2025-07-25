module Hotpages::Page::Renderable
  TEMPLATE_BASENAME_REGEXP = /\A_[^_]+/.freeze

  def render_layout? = layout_path && !layout_path.empty? && template.rendered_to_html?

  def render(partial_path = nil, **partial_locals)
    return render_partial(partial_path, **partial_locals) if partial_path

    page_content = template.render_in(self)

    render_layout do |content_name = nil|
      if content_name
        captured_contents[content_name.to_sym]
      else
        page_content
      end
    end
  end

  private

  def captured_contents = @captured_contents ||= {}

  # TODO: support ruby objects responds to `render_in`
  def partial_finder = @partial_finder ||= Hotpages::Page::PartialFinder.new(base_path, config)
  def render_partial(partial_path, **locals)
    partial = partial_finder.find_for(partial_path)
    template = Hotpages::Template.new(partial.extension, base_path: partial.base_path)
    template.render_in(self, locals)
  end

  def layout_template
    @layout_template ||=
      Hotpages::Template.new("html.erb", base_path: layout_path, path_prefix: config.site.layouts_full_path)
  end
  def render_layout(&block)
    if !render_layout?
      yield if block_given?
    else
      layout_template.render_in(self, &block)
    end
  end
end
