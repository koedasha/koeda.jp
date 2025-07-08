require_relative "lib/hotpages"

module Koeda
  class Site < Hotpages::Site
    config.root = __dir__
  end

  Site.instance.setup
end
