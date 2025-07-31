module Hotpages::ConfigurationExt
  class << self
    def extended(base)
      base.site.extend(SiteExt)
    end
  end

  module SiteExt
    def dist_full_path = full_path(dist_path)
    def config_full_path = full_path(config_path)
    def models_full_path = full_path(models_path)
    def helpers_full_path = full_path(helpers_path)
    def layouts_full_path = full_path(layouts_path)
    def assets_full_path = full_path(assets_path)
    def pages_full_path = full_path(pages_path)
    def shared_full_path = full_path(shared_path)

    def pages_namespace_module(ns_name = pages_namespace)
      return Object.const_get(ns_name) if Object.const_defined?(ns_name)

      Object.const_set(ns_name, Module.new)
    end

    private

    def full_path(path)
      File.expand_path(File.join(root, path))
    end
  end
end
