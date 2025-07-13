module Hotpages::Helpers::CaptureHelper
  def capture(&block) = @buf.capture(&block)

  def content_for(name, content = nil, &block)
    return captured_contents[name.to_sym] if !content && !block_given?

    content ||= capture(&block) if block_given?

    captured_contents[name.to_sym] = content
  end

  def content_for?(name)
    captured_contents.key?(name.to_sym)
  end
end
