require "#{__dir__}/lib/hotpages"

module Koeda
  class Site < Hotpages::Site
    config.root = __dir__
  end

  class Page < Hotpages::Page
    def site = @site ||= SiteProperties.new
    delegate [:title, :description] => :site
  end
end

Hotpages.setup_site(Koeda::Site)
