module Hotpages::Extensions::Hotwire
  extend Hotpages::Extension

  IMPORTMAPS = {
    "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.13/dist/turbo.es2017-esm.min.js",
    "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/+esm"
  }

  extension do
    it.add_helper Hotpages::Extensions::Hotwire::TurboHelper
    it.configure do |config|
      config.importmaps.merge!(IMPORTMAPS)
    end
  end

  Hotpages::Site.after_initialize do |site|
    site.assets_paths << "#{__dir__}/hotwire/assets"
  end
end
