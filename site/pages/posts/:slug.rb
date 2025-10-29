def self.segment_names = Post.slugs
def post = Post.find_by_slug(segments[:slug])
