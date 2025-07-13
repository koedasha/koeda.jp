class Page < Hotpages::Page
  include SiteHelper
  def site = @site ||= SiteProperties.new
  delegate [:title, :description] => :site
end
