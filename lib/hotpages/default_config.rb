module Hotpages
  DEFAULT_CONFIG = Configuration.new(
    page_base_class: Hotpages::Page,
    site: Configuration.new(
      root: nil,
      dist_path: "../_site",
      config_path: "config",
      models_path: "models",
      helpers_path: "helpers",
      layouts_path: "layouts",
      assets_path: "assets",
      shared_path: "shared",
      importmaps: {
        "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@latest/dist/turbo.es2017-esm.min.js",
        "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@latest/+esm"
      },
      pages_path: "pages",
      pages_namespace: "Pages",
    ),
    dev_server: Configuration.new(
      port: 4000
    )
  )
end
