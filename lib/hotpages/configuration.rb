class Hotpages::Configuration
  def initialize(defaults)
    defaults.each do |key, value|
      self.define_singleton_method(key) do
        instance_variable_get("@#{key}")
      end

      instance_variable_set("@#{key}", value)

      self.define_singleton_method("#{key}=") do |new_value|
        instance_variable_set("@#{key}", new_value)
      end
    end
  end

  def to_h
    hash = {}

    instance_variables.each do |var|
      key = var.to_s.delete("@").to_sym
      value = instance_variable_get(var)

      if value.is_a?(self.class)
        hash[key] = value.to_h
      else
        hash[key] = value
      end
    end

    hash
  end
end
