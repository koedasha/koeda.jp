require_relative "lib/hotpages"

module Koeda
  class Site < Hotpages::Site
    configure do |config|
      config.root = __dir__
    end
  end
end
