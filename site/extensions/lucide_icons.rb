require "rexml/document"

module LucideIcons
  extend Hotpages::Extension

  add_helper "#{name}::Helper"

  SPRITE_PATH = "#{__dir__}/lucide_icons/sprite.svg"
  SPRITE_XML = File.read(SPRITE_PATH)
  SPRITE_DOC = REXML::Document.new(SPRITE_XML)
  SVG_ATTRIBUTES = {
    "xmlns" => "http://www.w3.org/2000/svg",
    "width" => "24",
    "height" => "24",
    "viewBox" => "0 0 24 24",
    "fill" => "none",
    "stroke" => "currentColor",
    "stroke-width" => "2",
    "stroke-linecap" => "round",
    "stroke-linejoin" => "round"
  }

  class << self
    # Parsing xml is heavy, so cache result icon tag
    def lucide_tag_cache = @lucide_tag_cache ||= {}
  end

  module Helper
    def lucide_tag(icon_name)
      LucideIcons.lucide_tag_cache[icon_name.to_sym] ||= begin
        symbol = REXML::XPath.first(SPRITE_DOC, "//symbol[@id='#{icon_name}']")
        unless symbol
          raise "Lucide icon `#{icon_name}` was not found in sprite.svg"
        end

        tag.svg SVG_ATTRIBUTES do
          symbol.elements.map(&:to_s)
        end
      end
    end
  end
end
