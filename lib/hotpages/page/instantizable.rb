module Hotpages::Page::Instantizable
  include Hotpages::Page::Expandable

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def from_full_paths(paths, config:)
      files = paths.select { |f| File.file?(f) }
      base_path_exts_map = files.group_by { |file| remove_ext(file) }.transform_values do |files|
        files.map { |file| File.extname(file).sub(/^\./, "") }
      end
      base_path_exts_map.flat_map do |base_path, exts|
        config.page_base_class.from_path(base_path, exts:, config:)
      end
    end

    # TODO: support no ruby file erb
    def from_path(base_path, exts:, config:)
      page_base_path = base_path.sub(config.pages_full_path + "/", "")
      page_class = config.pages_namespace_module.const_get(page_base_path.classify, false)
      page_class.expand_instances_for(page_base_path, config:)
    end

    private

    def remove_ext(path)
      basename = File.basename(path)
      basename_without_exts = basename.sub(/\..*$/, '')
      File.join(File.dirname(path), basename_without_exts)
    end
  end
end
