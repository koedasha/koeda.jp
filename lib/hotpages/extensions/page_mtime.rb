module Hotpages::Extensions::PageMtime
  extend Hotpages::Extension

  including "#{name}::Page", to: "Hotpages::Page"
  including "#{name}::Template", to: "Hotpages::Page::Template"

  module Page
    def last_modified_at
      [ page_template.file_last_modified_at,
        ruby_file_last_modified_at ]
        .compact.max
    end

    private

    def ruby_file_last_modified_at
      path = site.pages_path.join(base_path, ".rb")
      File.file?(path) ? File.mtime(path) : nil
    end
  end

  module Template
    def file_last_modified_at = render_file? ? File.mtime(absolute_path) : nil
  end
end
