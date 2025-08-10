class Hotpages::Page::Finder
  using Hotpages::Refinements::String

  IGNORED_PATH_REGEXP = Hotpages::Page::Instantiation::IGNORED_PATH_REGEXP

  def initialize(site)
    @site = site
  end

  module Localizable
    def find(requested_path)
      locale_regexp = %r{\A/?(#{site.locales.join("|")})/}

      if site.locales.any? && requested_path =~ locale_regexp
        locale = $1
        unlocalized_path = "/" + requested_path.sub(locale_regexp, "")
        super(unlocalized_path).tap do |page|
          page.locale = locale if page
        end
      else
        super(requested_path)
      end
    end
  end
  prepend Localizable

  # Generic finding logic for pages based on the requested path.
  # TODO: Static O(1) finding logic for pages generation with instances cache
  def find(requested_path)
    page_base_class = Hotpages.page_base_class
    # Normalized as `foo/bar/index'
    page_path = normalize_path(requested_path)
    extension = File.extname(requested_path)
    extension = ".html" if extension.empty? # Assume HTML if no extension is provided

    segment_names = page_path.split("/")
    constant_names = page_path.classify.split("::")

    page_class = site.pages_namespace_module
    page_file_path = site.pages_path.to_s
    name = nil
    segments = {}

    segment_names.zip(constant_names).each.with_index do |(segment_name, constant_name), index|
      if (page_class.const_defined?(constant_name, false) rescue false)
        page_class = page_class.const_get(constant_name, false)
        page_file_path += "/#{segment_name}"
      else
        expandable_const_found = false

        page_class.constants(false).each do |const_name|
          const = page_class.const_get(const_name, false)
          next if !const.respond_to?(:segment_names) || !const.segment_names

          seg_names = const.segment_names.sort
          if seg_names.bsearch { _1.to_s >= segment_name }.to_s == segment_name
            page_class = const
            page_file_path += "/__#{const_name.to_s.underscore}__"
            name = segment_name
            segments[const_name.to_s.underscore.to_sym] = segment_name
            expandable_const_found = true
            break
          end
        end

        if !expandable_const_found
          if index == segment_names.size - 1 # handle file
            if phantom_page_class = page_base_class.page_subclass_under(page_class.name.split("::")[1..])
              page_class = phantom_page_class
              page_file_path += "/#{segment_name}"
            else
              return nil
            end
          else # handle directory
            page_class =
              if page_class.const_defined?(constant_name, false)
                page_class.const_get(constant_name, false)
              else
                page_class.const_set(constant_name, Module.new)
              end
            page_file_path += "/#{segment_name}"
          end
        end
      end
    end

    return nil unless page_class < page_base_class

    base_path = page_file_path.sub(site.pages_path.to_s, "").to_s.delete_prefix("/")

    return nil if base_path =~ IGNORED_PATH_REGEXP

    files = Dir.glob("#{page_file_path}.*")
    files += [page_file_path] if File.file?(page_file_path)
    non_rb_exts = files
      .map { |path| File.basename(path).split('.')[1..].join('.') }
      .reject { _1 == "rb" }
    template_extension = non_rb_exts.empty? ? nil : non_rb_exts.first

    page = page_class.new(base_path:, segments:, name:, template_extension:)

    return nil if page_class.phantom? && !page.template_file_exist?

    if "#{page_path}#{extension}" == page.expanded_base_path_with_extension ||
        page_path == page.expanded_base_path_with_extension # For paths without extension
      page
    else
      nil
    end
  end

  private

  attr_reader :site

  def normalize_path(path)
    path = path.delete_suffix(File.extname(path))
    path = "#{path}index" if path.end_with?("/")
    path = path.sub(%r{^/}, '') # Remove leading slash if present
    path
  end
end
