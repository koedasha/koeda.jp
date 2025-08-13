module Hotpages::Extensions::Hotwire
  extend Hotpages::Extension

  IMPORTMAPS = {
    "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.13/dist/turbo.es2017-esm.min.js",
    "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/+esm"
  }

  prepending "#{name}::Config", to: "Hotpages::Config"
  prepending "#{name}::Site", to: "Hotpages::Site"

  module Config
    module ClassMethods
      def defaults
        super.tap do |config|
          config.importmaps.merge!(IMPORTMAPS)
        end
      end
    end
  end

  module Site
    def assets_paths = super << "#{__dir__}/hotwire"
  end
end
