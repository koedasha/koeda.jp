class News < MarkdownArticle
  self.directory = "data/news"

  def title = data[:title]
  def date = data[:date]
end
