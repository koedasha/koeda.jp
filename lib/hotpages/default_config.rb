module Hotpages
  DEFAULT_CONFIG = {
    root: nil,
    site: Configuration.new(
      root: "site",
      models_path:"models",
      layouts_path: "layouts",
      assets_path: "assets",
      importmaps: {
        "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@latest/dist/turbo.es2017-esm.min.js",
        "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@latest/+esm"
      },
      pages_path: "pages",
      pages_namespace: "Pages",
      dist_path: "dist",
      dev_server: Configuration.new(
        port: 8080
      )
    )
  }.freeze
end
