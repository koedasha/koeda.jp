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

    def expand_instances_for(base_path, template_extension:)
      if expanded_names.nil?
        [ new(base_path: base_path, template_extension:) ]
      else
        # Convention check
        unless base_path =~ EXPANABLE_PATH_REGEXP
          raise ArgumentError, "On expanding, base path must be surrounded by [ and ] (e.g., '[post]')"
        end

        expanded_names.map do |name|
          new(base_path: base_path, name:, template_extension:)
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

  def expanded_path
    ext = template_extension&.split(".")&.first || "html"
    "#{expanded_base_path}.#{ext}"
  end
end
