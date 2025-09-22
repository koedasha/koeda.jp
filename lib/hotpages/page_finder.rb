class Hotpages::PageFinder
  using Hotpages::Support::StringInflections

  Directory = Hotpages::Directory
  Page = Hotpages::Page
  IGNORED_PATH_REGEXP = Page::Instantiation::IGNORED_PATH_REGEXP
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

    base_path = page_path.to_s.delete_prefix("#{site.pages_path}/")

    return nil if base_path =~ IGNORED_PATH_REGEXP

    files = Dir.glob("#{page_path}.*")
    files += [ page_path ] if File.file?(page_path)
    non_rb_exts = files
                  .map { |path| File.basename(path).split(".")[1..].join(".") }
                  .reject { it == "rb" }
    template_file_ext = non_rb_exts.empty? ? nil : non_rb_exts.first

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
    segment_names = requested_path.split("/")

    current_path = site.pages_path
    page_name = nil
    segments = {}

    # Convert requested path to file system path
    segment_names.each.with_index do |segment_name, index|
      is_last_segment = index == segment_names.size - 1

      if current_path.join(segment_name).directory? ||
         current_path.children(false).any? { it.basename.to_s.split(".").first == segment_name }
        current_path = current_path.join(segment_name)
      else
        expandable_const_found = false

        current_path.each_child do |child_path|
          const = if is_last_segment
            site.page_base_class.subclass_at_path(child_path)
          else
            Directory.subclass_at_path(child_path)
          end

          next unless const && const.segment_names

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
