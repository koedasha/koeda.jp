require "forwardable"

module Hotpages::Site::ConfigurationExt
  def site_full_path
    File.join(root, site.root)
  end

  def models_full_path
    File.join(site_full_path, site.models_path)
  end

  def layouts_full_path
    File.join(site_full_path, site.layouts_path)
  end

  def pages_full_path
    File.join(site_full_path, site.pages_path)
  end

  def dist_full_path
    File.join(root, site.dist_path)
  end

  def pages_namespace_module(ns_name = site.pages_namespace)
    return Object.const_get(ns_name) if Object.const_defined?(ns_name)

    Object.const_set(ns_name, Module.new)
  end
end
