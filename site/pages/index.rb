class Pages::Index
  include Hotpages::Page

  def site = @site ||= SiteInformation.new
  delegate [:title, :description] => :site
end
