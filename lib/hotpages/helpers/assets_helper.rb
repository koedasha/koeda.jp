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
    assets_path = config.site.assets_absolute_path
    file_imports =
      Dir.glob(File.join(assets_path, "**/*.js")).each.with_object({}) do |file, imports|
        relative_path = file.sub(assets_path + "/", "")
        next if relative_path == entrypoint
        imports[relative_path.to_sym] = asset_path(relative_path)
      end
    imports = {
      **file_imports,
      **config.site.importmaps.to_h
    }
    preloads = imports.map do |_key, path|
      path.end_with?("/") ? nil : tag.link(rel: "modulepreload", href: path)
    end.compact

    tag.script(type: "importmap") { JSON.pretty_generate({ imports: }, indent: "  ") } +
      "\n" +
      preloads.join("\n") +
      "\n" +
      tag.script(type: "module", src: asset_path(entrypoint))
  end
end
