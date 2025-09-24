class Hotpages::Directory < Hotpages::PagePathComponent
  class << self
    def subclass_at_path(directory_path)
      return nil if ignore_path?(directory_path)

      directory_path = absolute_path_of(directory_path)
      return nil unless File.directory?(directory_path)

      directory_ruby = "#{directory_path}.rb"
      ruby_mtime, ruby_file = if File.file?(directory_ruby)
        [ File.mtime(directory_ruby), directory_ruby ]
      else
        [ nil, nil ]
      end

      class_name = class_name_for(directory_path, prefix: "Directory_")
      new_subclass(class_name, ruby_file:, version: ruby_mtime)
    end
  end
end
