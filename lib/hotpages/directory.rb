class Hotpages::Directory < Hotpages::PagePathComponent
  class << self
    def subclass_at_path(directory_path)
      return nil if ignore_path?(directory_path)

      directory_path = absolute_path_of(directory_path)
      return nil unless File.directory?(directory_path)

      class_name = class_name_for(directory_path, prefix: "Directory_")
      directory_ruby = "#{directory_path}.rb"
      directory_ruby_mtime, directory_ruby_body = if File.file?(directory_ruby)
        [ File.mtime(directory_ruby), File.read(directory_ruby) ]
      else
        [ nil, nil ]
      end

      new_subclass(class_name, with_definition: directory_ruby_body, version: directory_ruby_mtime)
    end
  end
end
