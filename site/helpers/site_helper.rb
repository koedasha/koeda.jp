module SiteHelper
  def init_lucide_tag
    tag.script(src: "https://unpkg.com/lucide@latest") +
    tag.script do
      <<~JS
        lucide.createIcons();

        ["turbo:frame-load", "hotpages:reload:html"].forEach(function(event) {
          document.addEventListener(event, function() {
            lucide.createIcons();
          });
        });
      JS
    end
  end

  def icon_tag(icon_name, **options)
    tag.i(data: { lucide: icon_name }, **options)
  end
end
