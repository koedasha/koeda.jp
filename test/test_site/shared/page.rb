class Page < Hotpages::Page
  def site_properties = @site_properties ||= SiteProperties.new
  delegate %i[ title description ] => :site_properties
end
