module Hotpages
  DEFAULT_CONFIG = Configuration.new(
    importmaps: {
      "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@latest/dist/turbo.es2017-esm.min.js",
      "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@latest/+esm"
    },
    page_base_class: Hotpages::Page,
    site: Configuration.new(
      root: nil,
      dist_dir: "../_site",
      models_dir: "models",
      helpers_dir: "helpers",
      layouts_dir: "layouts",
      assets_dir: "assets",
      shared_dir: "shared",
      pages_dir: "pages",
      pages_namespace: "Pages",
      i18n: Configuration.new(
        locales: [],
        default_locale: nil,
        locales_dir: "locales",
        locale_file_format: :yaml
      )
    ),
    dev_server: Configuration.new(
      port: 4000,
      hot_reloading_enabled: true
    )
  )
end
