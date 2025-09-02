module Hotpages::Extensions::Hotwire
  extend Hotpages::Extension

  IMPORTMAPS = {
    "@hotwired/turbo": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.13/dist/turbo.es2017-esm.min.js",
    "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/+esm"
  }

  prepending to: "Hotpages::Site"
  add_helper "#{name}::TurboHelper"

  configure do |config|
    config.importmaps.merge!(IMPORTMAPS)
  end

  def self.prepended(site_class)
    site_class.after_initialize do |site|
      site.assets_paths << "#{__dir__}/hotwire/assets"
    end
  end
end
