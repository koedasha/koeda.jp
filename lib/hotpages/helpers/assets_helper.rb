require "json"

module Hotpages::Helpers::AssetsHelper
  def asset_path(asset_name)
    File.join("/", config.site.assets_path, asset_name)
  end

  # def asset_url(asset_name)
  #   File.join(config.site.base_url, config.site.assets_path, asset_name)
  # end

  def stylesheet_link_tag(stylesheet_name)
    "<link rel='stylesheet' href='#{asset_path(stylesheet_name)}.css'>"
  end

  def javascript_include_tag(script_name, type: "module")
    "<script type='#{type}' src='#{asset_path(script_name)}.js'></script>"
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
      #{JSON.pretty_generate(map)}
    </script>
    #{preloads.join("\n")}
    <script type="module" src="#{asset_path(entrypoint)}"></script>
    TAG
  end
end
