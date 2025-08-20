class Hotpages::Page::RenderingContext
  attr_reader :captured_contents
  attr_accessor :cached_page_content

  def initialize(page)
    @page = page
    @template_finder = Hotpages::Page::Template::Finder.new(page.base_path, page.site)
    @cached_page_content = nil
    @captured_contents = {}
    @buf = ""
  end

  def buffer = @buf

  # TODO: support ruby objects responds to `render_in`
  def render(template_path, **locals, &block)
    template = template_finder.find!(template_path)

    # TODO: block ignored warnings
    if block_given?
      template.render_in(self, locals, &block)
    else
      template.render_in(self, locals) do |content_name = nil|
        if content_name
          captured_contents[content_name.to_sym]
        else
          cached_page_content
        end
      end
    end
  end

  def copy_page_instance_variables!
    with_protecting_original_instance_variables do
      page.instance_variables.each do |name|
        value = page.instance_variable_get(name)
        instance_variable_set(name, value)
      end
    end
  end

  private

  attr_reader :page, :template_finder

  def respond_to_missing?(name, include_private = false)
    page.respond_to?(name, include_private)
  end

  def method_missing(method, *args, **kwargs, &block)
    page.send(method, *args, **kwargs, &block)
  end

  def with_protecting_original_instance_variables
    @original_instance_variables = instance_variables unless @original_instance_variables
    same_name_ivars = @original_instance_variables & page.instance_variables

    if same_name_ivars.any?
      raise "These variables are already defined in rendering context: #{same_name_ivars}"
    end

    yield
  end
end
