class Hotpages::PageFinder
  using Hotpages::Support::StringInflections

  IGNORED_PATH_REGEXP = Hotpages::Page::Instantiation::IGNORED_PATH_REGEXP

  def initialize(site)
    @site = site
  end

  # Generic finding logic for pages based on the requested path.
  # TODO: Static O(1) finding logic for pages generation with instances cache
  def find(requested_path)
    # Normalized as `foo/bar/index'
    page_path = normalize_path(requested_path)
    extension = File.extname(requested_path)
    extension = ".html" if extension.empty? # Assume HTML if no extension is provided

    segment_names = page_path.split("/")
    constant_names = page_path.classify.split("::")

    segment_constant = site.pages_namespace_module
    page_file_path = site.pages_path.to_s
    name = nil
    segments = {}

    segment_names.zip(constant_names).each.with_index do |(segment_name, constant_name), index|
      # First, lookup specific page class
      if (segment_constant.const_defined?(constant_name, false) rescue false)
        segment_constant = segment_constant.const_get(constant_name, false)
        page_file_path += "/#{segment_name}"
      else
        # If specific page class is not found, lookup segment names for expansion
        expandable_const_found = false

        segment_constant.constants(false).each do |const_name|
          const = segment_constant.const_get(const_name, false)
          next if !const.respond_to?(:segment_names) || !const.segment_names

          seg_names = const.segment_names.sort
          if seg_names.bsearch { it.to_s >= segment_name }.to_s == segment_name
            segment_constant = const
            page_file_path += "/__#{const_name.to_s.underscore}__"
            name = segment_name
            segments[const_name.to_s.underscore.to_sym] = segment_name
            expandable_const_found = true
            break
          end
        end

        if !expandable_const_found
          # Lookup generic *::Page class
          if index == segment_names.size - 1 # handle file
            if page_class = Hotpages::Page.page_subclass_under(segment_constant.name.split("::")[1..])
              segment_constant = page_class
              page_file_path += "/#{segment_name}"
            else
              return nil
            end
          else # handle directory
            segment_constant =
              if segment_constant.const_defined?(constant_name, false)
                segment_constant.const_get(constant_name, false)
              else
                segment_constant.const_set(constant_name, Module.new)
              end
            page_file_path += "/#{segment_name}"
          end
        end
      end
    end

    # segment_constant must be a Class, not a Module
    return nil unless segment_constant.is_a?(Class)

    base_path = page_file_path.sub(site.pages_path.to_s, "").to_s.delete_prefix("/")

    return nil if base_path =~ IGNORED_PATH_REGEXP

    files = Dir.glob("#{page_file_path}.*")
    files += [ page_file_path ] if File.file?(page_file_path)
    non_rb_exts = files
      .map { |path| File.basename(path).split(".")[1..].join(".") }
      .reject { it == "rb" }
    template_file_ext = non_rb_exts.empty? ? nil : non_rb_exts.first

    page = segment_constant.new(base_path:, segments:, name:, template_file_ext:)

    return nil if segment_constant.phantom? && !page.template_file_exist?

    page_url = page.expanded_url(omit_html_ext: false, omit_index: false)
    if "#{page_path}#{extension}" == page_url ||
        page_path == page_url # For paths without extension
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
    path = path.sub(%r{^/}, "") # Remove leading slash if present
    path
  end
end
