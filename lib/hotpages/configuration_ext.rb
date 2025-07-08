module Hotpages::ConfigurationExt
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
