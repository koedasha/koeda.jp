module SiteHelper
  def init_lucide_tag
    tag.script(src: "https://unpkg.com/lucide@latest").concat(
      tag.script { "lucide.createIcons()" }
    )
  end

  def icon_tag(icon_name, **options)
    tag.i(data: { lucide: icon_name }, **options)
  end
end
