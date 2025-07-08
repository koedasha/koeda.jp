class Hotpages::Configuration
  DEFAULTS = {
    root: nil,
    models_path:"models",
    site_path: "site",
    pages_path: "pages",
    dist_path: "dist",
    pages_namespace: "Pages",
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
