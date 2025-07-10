module SiteHelper
  def foo(&block)
    "<div id='foo'>#{@buf.capture(&block)}</div>"
  end
end
