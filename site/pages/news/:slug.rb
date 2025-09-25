def self.segment_names = News.slugs
def news = News.find_by_slug(segments[:slug])
