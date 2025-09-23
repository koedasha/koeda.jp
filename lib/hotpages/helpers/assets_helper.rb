require "json"

module Hotpages::Helpers::AssetsHelper
  def asset_path(asset_path, directory: nil)
    asset = Hotpages::Asset.new(asset_path, directory:)
    asset.url
  end

  def image_tag(image_path, **options)
    options[:src] = asset_path(image_path)
    tag.img options
  end

  def inline_svg_tag(svg_path, **options)
    svg_asset = Hotpages::Asset.new(svg_path)
    svg = site.cache.fetch(svg_path, version: svg_asset.mtime) do
      doc = REXML::Document.new(svg_asset.read_file)
      REXML::XPath.first(doc, "//svg")
    end

    raise "Failed to load svg definition: #{svg_path}" unless svg

    options.each do |k, v|
      svg.attributes[k.to_s] = v
    end

    svg.to_s
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
    file_imports =
      site.assets(".js").each.with_object({}) do |(base_path, file), imports|
        relative_path = file.sub(base_path.to_s, "").delete_prefix("/")
        next if relative_path == entrypoint
        imports[relative_path.delete_suffix(".js").to_sym] = asset_path(relative_path, directory: base_path)
      end
    imports = {
      **file_imports,
      **config.importmaps.to_h
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
