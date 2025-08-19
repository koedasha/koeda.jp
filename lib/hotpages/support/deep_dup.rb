module Hotpages::Support::DeepDup
  # Simple deep_dup implementation
  refine Object do
    def deep_dup
      # Return self for immutable objects
      return self if immutable?

      # Recursively duplicate arrays
      if is_a?(Array)
        map { |e| e.deep_dup }
      # Recursively duplicate hashes (both keys and values)
      elsif is_a?(Hash)
        each_with_object(self.class.new) do |(k, v), h|
          h[k.deep_dup] = v.deep_dup
        end
      else
        # Try to dup other objects; return self if duplication fails
        begin
          duped = dup
        rescue TypeError
          return self
        end

        # Recursively duplicate instance variables
        instance_variables.each do |ivar|
          val = instance_variable_get(ivar)
          duped.instance_variable_set(ivar, val.deep_dup)
        end

        duped
      end
    end

    private

    # Check if the object is immutable
    def immutable?
      self.is_a?(Symbol) || self.is_a?(Numeric) ||
        self.is_a?(TrueClass) || self.is_a?(FalseClass) ||
        self.nil?
    end
  end
end
