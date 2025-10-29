class Post < MarkdownArticle
  self.directory = "data/posts"

  def title = data[:title]
  def date = data[:date]
end
