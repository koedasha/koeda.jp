module Hotpages::Page::Expandable
  EXPANABLE_PATH_REGEXP = /\[(.*)\](\.\w+)*\z/.freeze
  EXPANDABLE_BASENAME_REGEXP = /\A#{EXPANABLE_PATH_REGEXP}/.freeze

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def expanded_names = nil

    def expand_instances_for(base_path)
      if expanded_names.nil?
        [ new(base_path: base_path) ]
      else
        # Convention check
        unless base_path =~ EXPANABLE_PATH_REGEXP
          raise ArgumentError, "On expanding, base path must be surrounded by [ and ] (e.g., '[post]')"
        end

        expanded_names.map do |name|
          new(base_path: base_path, name:)
        end
      end
    end
  end

  def expanded_base_path
    dirname = File.dirname(base_path)

    if dirname == "."
      name
    else
      File.join(dirname, name)
    end
  end
end
