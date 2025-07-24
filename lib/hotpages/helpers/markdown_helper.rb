module Hotpages::Helpers::MarkdownHelper
  def render_markdown(markdown_text = nil, **locals, &body)
    content = markdown_text || capture(&body)
    return "" if !content || content.strip.empty?

    lines = content.lines
    while lines.first =~ /^\s*$/ # Remove leading empty lines
      lines.shift
    end

    leading_whitespaces = /\A(\s*)/.match(lines.first)[1] || ""
    unindented_content = lines.map do |line|
      if line.start_with?(leading_whitespaces)
        line[leading_whitespaces] = "" # Remove leading whitespaces
      end

      line
    end.join

    template = Hotpages::Template.new("md.erb") { unindented_content }
    template.render_in(self, locals)
  end
end
