module Hotpages::Support::StringInflections
  refine String do
    def underscore
      gsub(/::/, "/")
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr("-", "_")
        .downcase
    end

    def camelize
      split("_").map(&:capitalize).join
    end

    def classify
      split("/").map(&:camelize).join("::")
    end

    def constantize
      Object.const_get(self)
    end
  end
end
