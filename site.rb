require_relative "lib/hotpages"

Hotpages.loader.setup

module Koeda
  class Site < Hotpages::Site
    config.root = __dir__
  end
end

Hotpages.setup_site(Koeda::Site)
