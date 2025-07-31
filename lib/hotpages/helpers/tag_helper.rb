module Hotpages::Helpers::TagHelper
  class Tag
    def initialize(context)
      @context = context
    end

    def method_missing(name, options = {}, &block)
      render(name, **options, &block)
    end

    def render(name, **options, &block)
      attributes = attributes_string(options)
      content = block_given? ? context.capture(&block) : ""
      normalized_name = name.to_s.tr("_", "-")

      "<#{normalized_name} #{attributes}>#{content}</#{normalized_name}>"
    end

    private

    attr_reader :context

    def attributes_string(attributes, key_prefix: "")
      attributes.map do |key, value|
        normalized_key = key.to_s.tr("_", "-")

        if value.is_a?(Hash)
          attributes_string(value, key_prefix: "#{key_prefix}#{normalized_key}-")
        else
          normalized_value = value.is_a?(String) ? value : value.to_s.tr("_", "-")
          "#{key_prefix}#{normalized_key}=\"#{normalized_value}\""
        end
      end.join(" ")
    end
  end
  def tag = @tag ||= Tag.new(self)
end
