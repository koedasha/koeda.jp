require_relative "lib/hotpages"

Hotpages.setup

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
