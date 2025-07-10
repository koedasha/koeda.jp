module AssetsHelper
  def image_path(image_name)
    File.join("/", config.site.assets_path, "images", image_name)
  end
end
