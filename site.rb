require "#{__dir__}/lib/hotpages"

module Koeda
  class Page < Hotpages::Page
    def site = @site ||= SiteProperties.new
    delegate [:title, :description] => :site
  end

  class Site < Hotpages::Site
    config.root = __dir__
    config.page_base_class = Koeda::Page
  end
end

Hotpages.setup_site(Koeda::Site)
