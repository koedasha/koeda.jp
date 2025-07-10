module Hotpages::Page::Expandable
  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def expanded_ids = nil

    def expand_instances_for(base_path)
      if expanded_ids.nil?
        [ new(base_path: base_path) ]
      else
        # Convention check
        unless File.basename(base_path).start_with?("_")
          raise ArgumentError, "On expanding, base path must starts with an underscore prefix (e.g., '_products')"
        end

        expanded_ids.map do |id|
          new(base_path: base_path, id:)
        end
      end
    end
  end

  def expanded_base_path
    File.join(base_path.split("/")[0..-2].join("/"), id)
  end
end
