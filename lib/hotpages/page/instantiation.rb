module Hotpages::Page::Instantiation
  include Hotpages::Page::Expandable

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def from_full_paths(paths)
      files = paths.map { File.expand_path(_1) }.select { |f| File.file?(f) }
      base_path_exts_map = files.group_by { |file| remove_ext(file) }.transform_values do |files|
        files.map { |file| (File.basename(file).split('.')[1..] || []).join('.') }
      end
      base_path_exts_map.flat_map do |base_path, exts|
        non_rb_exts = exts.reject { |ext| ext == "rb" }

        raise "Multiple page templates found for #{base_path}: #{non_rb_exts.join(', ')}" if non_rb_exts.size > 1

        from_path(base_path, template_extension: non_rb_exts.first) || []
      end
    end

    def from_path(base_path, template_extension:)
      filename = File.basename(base_path)

      return nil if filename =~ Hotpages::Page::Renderable::TEMPLATE_BASENAME_REGEXP

      page_base_path = base_path.sub(config.site.pages_full_path + "/", "")

      class_name = page_base_path.classify
      page_class = config.site.pages_namespace_module.const_get(class_name, false) rescue config.page_base_class

      page_class.expand_instances_for(page_base_path, template_extension:)
    end

    private

    def remove_ext(path)
      basename = File.basename(path)
      basename_without_exts = basename.sub(/\..*$/, '')
      File.join(File.dirname(path), basename_without_exts)
    end
  end
end
