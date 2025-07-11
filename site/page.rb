class Page < Hotpages::Page
  helper SiteHelper, TurboHelper

  def site = @site ||= SiteProperties.new
  delegate [:title, :subtitle, :description] => :site
end
