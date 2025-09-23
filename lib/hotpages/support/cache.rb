# Provides simple version based cache
module Hotpages::Support::Cache
  Entry = Data.define(:version, :content) do
    def content_of(of_version)
      # consider nil as version 0
      if (version || 0) < (of_version || 0)
        nil
      else
        content
      end
    end
  end

  class Store < Hash
    def fetch(cache_key, version:)
      self[cache_key]&.content_of(version) ||
        yield.tap do |content|
          self[cache_key] = Entry.new(version:, content:)
        end
    end
  end
end
