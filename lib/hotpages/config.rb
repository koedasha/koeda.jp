class Hotpages::Config
  class << self
    def defaults
      new(
        importmaps: {
          "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.13/dist/turbo.es2017-esm.min.js",
          "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/+esm"
        },
        assets: new(
          prefix: "/assets/",
        ),
        site: new(
          root: nil,
          dist_dir: "../_site",
          models_dir: "models",
          helpers_dir: "helpers",
          layouts_dir: "layouts",
          assets_dir: "assets",
          shared_dir: "shared",
          pages_dir: "pages",
          pages_namespace: "Pages",
          generator: new(
            # Url prefix for page URLs when generating static files.
            # Set this when deploying the site to a subdirectory.
            links_base_url: ""
          )
        ),
        dev_server: new(
          port: 4000,
          hot_reloading_enabled: true,
          backtrace_link_format: "vscode://file/%{file}:%{line}",
        )
      )
    end
  end

  def initialize(defaults)
    defaults.each do |key, value|
      define_attribute(key, value)
    end
  end

  def add(**configs)
    configs.each do |key, value|
      define_attribute(key, value)
    end
    self
  end

  def to_h
    hash = {}

    instance_variables.each do |var|
      key = var.to_s.delete("@").to_sym
      value = instance_variable_get(var)

      if value.is_a?(self.class)
        hash[key] = value.to_h
      else
        hash[key] = value
      end
    end

    hash
  end

  private

  def define_attribute(name, value)
    self.define_singleton_method(name) do
      instance_variable_get("@#{name}")
    end

    instance_variable_set("@#{name}", value)

    self.define_singleton_method("#{name}=") do |new_value|
      instance_variable_set("@#{name}", new_value)
    end
  end
end
