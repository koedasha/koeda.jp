require "front_matter_parser"

class MarkdownArticle
  class << self
    attr_accessor :directory

    def slugs(site: Hotpages.site)
      site.root.join(directory).children.map do
        it.basename.to_s.split(".").first
      end
    end

    def find_by_slug(slug)
      all.find { it.slug == slug }
    end

    def all(site: Hotpages.site)
      site.root.join(directory).children.map do
        loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [ Date, Time ])
        parsed = FrontMatterParser::Parser.new(:md, loader: loader).call(it.read)
        data = parsed.front_matter.map do |(k, v)|
          [ k.to_sym, v ]
        end.to_h

        new(slug: it.basename.to_s.split(".").first, content: parsed.content, data:)
      end
    end
  end

  attr_accessor :slug, :content, :data

  def initialize(slug:, content:, data: {})
    @slug = slug
    @content = content
    @data = data
  end
end
