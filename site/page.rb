class Page < Hotpages::Page
  include SiteHelper, TurboHelper

  def site = @site ||= SiteProperties.new
  delegate [:title, :subtitle, :description] => :site
end
