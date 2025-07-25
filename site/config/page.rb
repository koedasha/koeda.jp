class Page < Hotpages::Page
  include SiteHelper

  def header? = true
  def site = @site ||= SiteProperties.new
  delegate [:title, :subtitle, :description] => :site
end
