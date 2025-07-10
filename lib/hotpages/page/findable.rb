module Hotpages::Page::Findable
  include Hotpages::Page::Instantiation

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def find_by_path(path)
      finder.find_for(path)
    end

    def exists?(path)
      !!find_by_path(path)
    end

    private

    def finder
      @finder ||= Hotpages::Page::Finder.new(config)
    end
  end
end
