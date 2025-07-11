module Hotpages
  DEFAULT_CONFIG = Configuration.new(
    page_base_class: Hotpages::Page, # TDOO: will be used for erb only pages
    site: Configuration.new(
      root: nil,
      dist_path: "../dist",
      models_path:"models",
      helpers_path:"helpers",
      layouts_path: "layouts",
      assets_path: "assets",
      importmaps: {
        "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@latest/dist/turbo.es2017-esm.min.js",
        "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@latest/+esm"
      },
      pages_path: "pages",
      pages_namespace: "Pages",
      partials_path: "partials",
      dev_server: Configuration.new(
        port: 8080
      )
    )
  )
end
