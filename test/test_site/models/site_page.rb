class SitePage < Hotpages::Page
  helper SiteHelper
  def site = @site ||= SiteProperties.new
  delegate [:title, :description] => :site
end
