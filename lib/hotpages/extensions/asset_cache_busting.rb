module Hotpages::Extensions::AssetCacheBusting
  extend Hotpages::Extension

  prepending to: "Hotpages::Helpers::AssetsHelper"

  def asset_path(asset_name, directory: nil)
    asset = Hotpages::Asset.new(asset_name, directory:)
    asset.digested_url
  end
end
