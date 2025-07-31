require "json"

module Hotpages::Helpers::AssetsHelper
  def asset_path(asset_name)
    url = File.join("/", config.site.assets_path, asset_name)
    # For busting cache
    assets_version = Hotpages.site.generating? ? Hotpages.site.assets_version : nil
    params = { v: assets_version }.compact
    compose_url(url, **params)
  end

  def image_path(image_name)
    asset_path(File.join("images", image_name))
  end

  def image_tag(image_name, **options)
    options[:src] = image_path(image_name)
    tag.img options
  end

  def stylesheet_link_tag(stylesheet_name)
    stylesheet_name = "#{stylesheet_name.delete_suffix(".css")}.css"
    tag.link rel: "stylesheet", href: asset_path(stylesheet_name)
  end

  def javascript_include_tag(script_name, type: "module")
    script_name = "#{script_name.delete_suffix(".js")}.js"
    tag.script type: type, src: asset_path(script_name)
  end

  def javascript_importmap_tags(entrypoint: "site.js")
    map = {
      imports: {
        "#{config.site.assets_path}/": "/#{config.site.assets_path}/",
        **config.site.importmaps.to_h
      }
    }
    preloads = map[:imports].map do |_key, path|
      path.end_with?("/") ? nil : "<link rel='modulepreload' href='#{path}'>"
    end.compact

    <<~TAG
      <script type="importmap">
      #{JSON.pretty_generate(map, indent: "  ")}
      </script>
      #{preloads.join("\n")}
      <script type="module" src="#{asset_path(entrypoint)}"></script>
    TAG
  end
end
