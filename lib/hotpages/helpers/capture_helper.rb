module Hotpages::Helpers::CaptureHelper
  def capture(*, **, &block)
    val = nil
    buffer = ctx.buffer.capture { val = yield(*, **) }

    # if yield returns non buffer value, it will be returned directly
    if ctx.buffer.equal?(val)
      buffer
    else
      val
    end
  end
  def concat(value) = ctx.buffer.concat(value)

  def content_for(name, content = nil, &block)
    return ctx.captured_contents[name.to_sym] if !content && !block_given?

    content ||= capture(&block) if block_given?

    ctx.captured_contents[name.to_sym] = content
  end

  def content_for?(name)
    ctx.captured_contents.key?(name.to_sym)
  end

  private

  def ctx = rendering_context
end
