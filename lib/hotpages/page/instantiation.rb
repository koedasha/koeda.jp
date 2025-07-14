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
        # TODO: support multiple exts like `index.html.erb`
        files.map { |file| File.extname(file).sub(/^\./, "") }
      end
      base_path_exts_map.flat_map do |base_path, exts|
        config.page_base_class.from_path(base_path, exts:)
      end
    end

    # TODO: support no ruby file erb
    def from_path(base_path, exts:)
      page_base_path = base_path.sub(config.site.pages_full_path + "/", "")
      page_class = config.site.pages_namespace_module.const_get(classify_base_path(page_base_path), false) rescue nil
      return [] unless page_class
      page_class.expand_instances_for(page_base_path)
    end

    private

    def remove_ext(path)
      basename = File.basename(path)
      basename_without_exts = basename.sub(/\..*$/, '')
      File.join(File.dirname(path), basename_without_exts)
    end

    def classify_base_path(base_path)
      pathnames = base_path.split("/")
      filename = pathnames.pop
      return nil if filename =~ Hotpages::Page::Renderable::TEMPLATE_BASENAME_REGEXP
      normalized_filename =
        filename.match(Hotpages::Page::Expandable::EXPANDABLE_BASENAME_REGEXP) ? $1 : filename
      pathnames.push(normalized_filename)
      pathnames.join("/").classify
    end
  end
end
