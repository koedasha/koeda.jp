require "forwardable"

module Hotpages::Site::ConfigurationExt
  def models_full_path
    File.join(site.root, site.models_path)
  end

  def helpers_full_path
    File.join(site.root, site.helpers_path)
  end

  def layouts_full_path
    File.join(site.root, site.layouts_path)
  end

  def assets_full_path
    File.join(site.root, site.assets_path)
  end

  def pages_full_path
    File.join(site.root, site.pages_path)
  end

  def partials_full_path
    File.join(site.root, site.partials_path)
  end

  def dist_full_path
    File.join(site.root, site.dist_path)
  end

  def pages_namespace_module(ns_name = site.pages_namespace)
    return Object.const_get(ns_name) if Object.const_defined?(ns_name)

    Object.const_set(ns_name, Module.new)
  end
end
