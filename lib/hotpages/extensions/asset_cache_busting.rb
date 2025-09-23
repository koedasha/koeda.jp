module Hotpages::Extensions::AssetCacheBusting
  extend Hotpages::Extension

  extension do
    it.prepend to: Hotpages::Helpers::AssetsHelper
  end

  def asset_path(asset_name, directory: nil)
    asset = Hotpages::Asset.new(asset_name, directory:)
    asset.digested_url
  end
end
