class Hotpages::Configuration
  DEFAULTS = {
    root: nil,
    models_path:"models",
    site_path: "site",
    pages_path: "pages",
    dist_path: "dist",
    pages_namespace: "Pages",
  }.freeze

  DEFAULTS.each do |key, value|
    define_method(key) do
      instance_variable_get("@#{key}")
    end

    define_method("#{key}=") do |new_value|
      instance_variable_set("@#{key}", new_value)
    end
  end

  def initialize(attributes = {})
    DEFAULTS.dup.merge(attributes).each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def site_full_path
    File.join(root, site_path)
  end

  def models_full_path
    File.join(site_full_path, models_path)
  end

  def pages_full_path
    File.join(site_full_path, pages_path)
  end

  def dist_full_path
    File.join(root, dist_path)
  end

  def pages_namespace_module(ns_name = pages_namespace)
    return Object.const_get(ns_name) if Object.const_defined?(ns_name)

    Object.const_set(ns_name, Module.new)
  end
end
