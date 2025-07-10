module Hotpages::Page::Findable
  include Hotpages::Page::Instantiation

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def find_by_path(path, config:)
      finder = Hotpages::Page::Finder.new(config)
      finder.find_for(path)
    end
  end
end
