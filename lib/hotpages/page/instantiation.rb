module Hotpages::Page::Instantiation
  using Hotpages::Support::StringInflections

  IGNORED_PATH_REGEXP = /\/_[^_]/.freeze

  def all
    all_page_files = Dir.glob(site.pages_path.join("**/*"))
    from_absolute_paths(all_page_files)
  end

  # TODO: name and caching
  def subclass_at_path(page_path)
    page_path = remove_all_ext(absolute_path_of(page_path))

    directory = Hotpages::Directory.subclass_at_path(page_path)
    return nil if directory && directory.segment_names

    files_at_path = Dir.glob("#{page_path}.*")
    return nil if !File.file?(page_path) && files_at_path.empty?

    class_name = class_name_for(page_path, prefix: "Page_")

    page_ruby = "#{page_path}.rb"
    generic_page_ruby = "#{File.dirname(page_path)}/_page.rb"

    ruby_body = if File.file?(page_ruby)
      File.read(page_ruby)
    elsif File.file?(generic_page_ruby)
      File.read(generic_page_ruby)
    else
      nil
    end

    klass = Class.new(self).tap do
      it.class_eval(ruby_body) if ruby_body
    end

    Object.const_set(class_name, klass)
  end

  private

  def from_absolute_paths(paths)
    page_paths = paths.inject([]) do |result, path|
      next result unless path.start_with?(site.pages_path.to_s)

      next result if path =~ IGNORED_PATH_REGEXP

      absolute_path = File.expand_path(path)

      File.file?(absolute_path) ? result << path : result
    end

    extensions_by_page_paths = page_paths.group_by { |path| remove_all_ext(path) }.transform_values do |paths|
      paths.map { |path| (File.basename(path).split(".")[1..] || []).join(".") }
    end

    extensions_by_page_paths.flat_map do |page_path, exts|
      non_rb_exts = exts.reject { |ext| ext == "rb" }

      raise "Multiple page templates found for #{base_path}: #{non_rb_exts.join(', ')}" if non_rb_exts.size > 1

      page_class = site.page_base_class.subclass_at_path(page_path)

      if page_class && page_class.respond_to?(:expand_instances_for)
        base_path = page_path.delete_prefix("#{site.pages_path}/")
        page_class.expand_instances_for(base_path, template_file_ext: non_rb_exts.first)
      else
        []
      end
    end
  end

  def remove_all_ext(path)
    basename = File.basename(path)
    basename_without_exts = basename.sub(/\..*$/, "")
    dirname = File.dirname(path)
    File.join(*[ dirname == "." ? nil : dirname, basename_without_exts ].compact)
  end
end
