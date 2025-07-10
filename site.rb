require "#{__dir__}/lib/hotpages"

module Koeda
  class Site < Hotpages::Site
    config.root = __dir__
  end
  Hotpages.setup_site(Site)

  class Page < Hotpages::Page
    helper SiteHelper, TurboHelper

    def site = @site ||= SiteProperties.new
    delegate [:title, :subtitle, :description] => :site
  end
  Hotpages.config.page_base_class = Koeda::Page
end
