class Page < Hotpages::Page
  include SiteHelper

  def site = @site ||= SiteProperties.new
  delegate [:title, :subtitle, :description] => :site
end
