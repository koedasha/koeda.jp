module Hotpages::Helpers::CaptureHelper
  def capture(*, **, &block)
    val = nil
    buffer = @buf.capture { val = yield(*, **) }

    # if yield returns non buffer value, it will be returned directly
    if @buf.equal?(val)
      buffer
    else
      val
    end
  end
  def concat(value) = @buf.concat(value)

  def content_for(name, content = nil, &block)
    return captured_contents[name.to_sym] if !content && !block_given?

    content ||= capture(&block) if block_given?

    captured_contents[name.to_sym] = content
  end

  def content_for?(name)
    captured_contents.key?(name.to_sym)
  end
end
