module Hotpages::Helpers::AssetsHelper
  def asset_path(asset_name)
    File.join(config.site.assets_path, asset_name)
  end

  # def asset_url(asset_name)
  #   File.join(config.site.base_url, config.site.assets_path, asset_name)
  # end

  def stylesheet_link_tag(stylesheet_name)
    "<link rel='stylesheet' href='#{asset_path(stylesheet_name)}.css'>"
  end

  def javascript_include_tag(script_name)
    "<script src='#{asset_path(script_name)}.js'></script>"
  end
end
