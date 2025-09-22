class Hotpages::PageFinder
  using Hotpages::Support::StringInflections

  Directory = Hotpages::Directory
  Page = Hotpages::Page
  EXPANDABLE_PATH_COMPONENT_REGEXP = Page::EXPANDABLE_NAME_REGEXP

  def initialize(site)
    @site = site
  end

  # Generic finding logic for pages based on the requested path.
  # TODO: Static O(1) finding logic utilizing instances cache for pages generation
  def find(requested_path)
    # Normalized as `foo/bar/index'
    extension = File.extname(requested_path)
    extension = ".html" if extension.empty? # Assume HTML if no extension is provided
    requested_path = normalize_path(requested_path)

    page_path, page_name, segments = parse_requested_path(requested_path)

    return nil unless page_path

    page_class = site.page_base_class.subclass_at_path(page_path)

    return nil unless page_class

    base_path = page_path.to_s.delete_prefix("#{site.pages_path}/")

    template_file_ext = page_path.dirname.children.find do
      !it.directory? &&
        it.to_s.start_with?(page_path.to_s) &&
        !it.to_s.end_with?(".rb")
    end.then do
      break nil unless it
      it.basename.to_s.split(".")[1..].join(".")
    end

    page = page_class.new(base_path:, segments:, name: page_name, template_file_ext:)

    page_url = page.expanded_url(omit_html_ext: false, omit_index: false)
    if "#{requested_path}#{extension}" == page_url ||
        requested_path == page_url # For paths without extension
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

  def parse_requested_path(requested_path)
    current_path = site.pages_path
    page_name = nil
    segments = {}

    segment_names = requested_path.split("/")
    segment_names.each.with_index do |segment_name, index|
      is_last_segment = index == segment_names.size - 1

      if current_path.children(false).any? { it.to_s.split(".").first == segment_name }
        current_path = current_path.join(segment_name)
      else
        expandable_const_found = false

        current_path.each_child do |child_path|
          const = if is_last_segment
            site.page_base_class.subclass_at_path(child_path)
          else
            Directory.subclass_at_path(child_path)
          end

          next unless const && const.expandable?

          seg_names = const.segment_names.sort
          if seg_names.bsearch { it.to_s >= segment_name }.to_s == segment_name
            path_component = child_path.basename.to_s
            current_path = current_path.join(path_component).sub_ext("")
            segment_key = path_component.match(EXPANDABLE_PATH_COMPONENT_REGEXP)[1].to_sym
            segments[segment_key] = segment_name
            page_name = segment_name
            expandable_const_found = true
            break
          end
        end

        return [ nil, nil, {} ] unless expandable_const_found
      end
    end

    [ current_path, page_name, segments ]
  end
end
