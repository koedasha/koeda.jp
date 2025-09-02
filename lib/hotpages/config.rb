class Hotpages::Config
  class << self
    def defaults
      new(
        importmaps: {},
        assets: new(
          prefix: "/assets/",
        ),
        site: new(
          # The root path property is set by the framework. Can be overridden when defining the Site.
          root: nil,
          # dist_path should be relative to the root, or absolute path.
          dist_path: "../_site",
          directory: new(
            pages: "pages",
            models: "models",
            layouts: "layouts",
            helpers: "helpers",
            assets: "assets",
            shared: "shared"
          ),
          pages_namespace: "Pages",
          phantom_page_base_class_name: "Page",
          generator: new(
            # Url prefix for page URLs when generating static files.
            # Set this when deploying the site to a subdirectory.
            links_url_prefix: ""
          )
        ),
        dev_server: new(
          port: 4000,
          backtrace_link_format: "vscode://file/%{file}:%{line}",
        )
      )
    end
  end

  def initialize(defaults = {}) = add(**defaults)

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
    # Do not re-define
    return if respond_to?(name)

    self.define_singleton_method(name) do
      instance_variable_get("@#{name}")
    end

    instance_variable_set("@#{name}", value)

    self.define_singleton_method("#{name}=") do |new_value|
      instance_variable_set("@#{name}", new_value)
    end
  end
end
