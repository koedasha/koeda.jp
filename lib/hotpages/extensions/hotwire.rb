module Hotpages::Extensions::Hotwire
  extend Hotpages::Extension

  IMPORTMAPS = {
    "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.13/dist/turbo.es2017-esm.min.js",
    "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/+esm"
  }

  prepending to: "Hotpages::Site"

  def self.prepended(site_class)
    site_class.after_setup do
      self.assets_paths << "#{__dir__}/hotwire"
      config.importmaps.merge!(IMPORTMAPS)
    end
  end
end
