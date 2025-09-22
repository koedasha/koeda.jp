class Hotpages::Directory < Hotpages::PagePathComponent
  class << self
    # TODO: Module name and caching
    def subclass_at_path(directory_path)
      directory_path = absolute_path_of(directory_path)
      return nil unless File.directory?(directory_path)

      directory_ruby = "#{directory_path}.rb"
      directory_ruby_body = if File.file?(directory_ruby)
        File.read(directory_ruby)
      else
        nil
      end

      Class.new(self).tap do
        it.module_eval(directory_ruby_body) if directory_ruby_body
      end
    end
  end
end
