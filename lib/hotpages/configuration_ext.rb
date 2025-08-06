module Hotpages::ConfigurationExt
  class << self
    def extended(base)
      base.site.extend(SiteExt)
    end
  end

  module SiteExt
    def dist_absolute_path = absolute_path(dist_dir)
    def models_absolute_path = absolute_path(models_dir)
    def helpers_absolute_path = absolute_path(helpers_dir)
    def layouts_absolute_path = absolute_path(layouts_dir)
    def assets_absolute_path = absolute_path(assets_dir)
    def pages_absolute_path = absolute_path(pages_dir)
    def shared_absolute_path = absolute_path(shared_dir)

    def pages_namespace_module(ns_name = pages_namespace)
      return Object.const_get(ns_name) if Object.const_defined?(ns_name)

      Object.const_set(ns_name, Module.new)
    end

    private

    def absolute_path(path)
      File.expand_path(File.join(root, path))
    end
  end
end
