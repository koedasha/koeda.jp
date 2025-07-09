class SitePage < Hotpages::Page
  def site = @site ||= SiteProperties.new
  delegate [:title, :description] => :site
end
