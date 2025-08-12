module Hotpages
  DEFAULT_CONFIG = Config.new(
    importmaps: {
      "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.13/dist/turbo.es2017-esm.min.js",
      "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/+esm"
    },
    assets: Config.new(
      prefix: "/assets/",
    ),
    site: Config.new(
      root: nil,
      dist_dir: "../_site",
      models_dir: "models",
      helpers_dir: "helpers",
      layouts_dir: "layouts",
      assets_dir: "assets",
      shared_dir: "shared",
      pages_dir: "pages",
      pages_namespace: "Pages",
      generator: Config.new(
        # Url prefix for page URLs when generating static files.
        # Set this when deploying the site to a subdirectory.
        links_base_url: ""
      ),
      i18n: Config.new(
        locales: [],
        default_locale: nil,
        locales_dir: "locales",
        locale_file_format: :yaml
      )
    ),
    dev_server: Config.new(
      port: 4000,
      hot_reloading_enabled: true,
      backtrace_link_format: "vscode://file/%{file}:%{line}",
    )
  )
end
