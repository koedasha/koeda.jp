class Hotpages::Configuration
  DEFAULTS = {
    root: nil,
    dist_path: "dist",
    site_path: "site",
    pages_namespace: "Pages",
    models_path:"models",
    pages_path: "pages",
    # site: {
    #   root: "site",
    #   models_path:"models",
    #   pages_path: "pages",
    #   pages_namespace: "Pages",
    # },
    dev_server: {
      port: 8080
    }
  }.freeze

  def initialize(defaults = DEFAULTS)
    defaults.each do |key, value|
      self.define_singleton_method(key) do
        instance_variable_get("@#{key}")
      end

      if value.is_a?(Hash)
        instance_variable_set("@#{key}", self.class.new(value))
      else
        instance_variable_set("@#{key}", value)

        self.define_singleton_method("#{key}=") do |new_value|
          instance_variable_set("@#{key}", new_value)
        end
      end
    end
  end
end
