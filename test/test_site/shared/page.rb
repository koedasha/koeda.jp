class Page < Hotpages::Page
  include SiteHelper
  def site = @site ||= SiteProperties.new
  delegate %i[ title description ] => :site
end
