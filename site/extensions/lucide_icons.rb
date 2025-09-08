require "rexml/document"

module LucideIcons
  extend Hotpages::Extension

  extension do
    it.add_helper Helper
  end

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
    def lucide_svg_drawing_for(icon_name)
      # Parsing xml is heavy, so cache result svg drawings
      @lucide_svg_drawings ||= {}
      @lucide_svg_drawings[icon_name] ||= begin
        symbol = REXML::XPath.first(SPRITE_DOC, "//symbol[@id='#{icon_name}']")
        unless symbol
          raise "Lucide icon `#{icon_name}` was not found in sprite.svg"
        end

        symbol.elements.map(&:to_s)
      end
    end
  end

  module Helper
    def lucide_tag(icon_name)
      tag.svg SVG_ATTRIBUTES do
        LucideIcons.lucide_svg_drawing_for(icon_name)
      end
    end
  end
end
