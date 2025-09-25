require "front_matter_parser"

News = Data.define(:slug, :date, :title, :author, :body) do
  DIRECTORY = "data/news"

  class << self
    def slugs(site: Hotpages.site)
      site.root.join(DIRECTORY).children.map do
        it.basename.to_s.split(".").first
      end
    end

    def find_by_slug(slug)
      all.find { it.slug == slug }
    end

    def all(site: Hotpages.site)
      site.root.join(DIRECTORY).children.map do
        loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [ Date ])
        parsed = FrontMatterParser::Parser.new(:md, loader: loader).call(it.read)
        fm = parsed.front_matter

        new(
          slug: it.basename.to_s.split(".").first,
          date: fm["date"],
          title: fm["title"],
          author: fm["author"],
          body: parsed.content
        )
      end
    end
  end
end
