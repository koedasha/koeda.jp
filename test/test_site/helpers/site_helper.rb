module SiteHelper
  def foo(&block)
    "<div id='foo'>#{capture(&block)}</div>"
  end
end
