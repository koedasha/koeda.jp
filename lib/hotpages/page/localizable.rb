require "fast_gettext/translation"

module Hotpages::Page::Localizable
  include Hotpages::Page::Expandable,
          Hotpages::Page::Renderable

  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    include Hotpages::Page::Expandable::ClassMethods

    def expand_instances_for(...)
      instances = super
      instances.flat_map do |instance|
        localized_instances = site.locales_without_default.map do |locale|
          instance.dup.tap do
            _1.locale = locale
            _1.extend(FastGettext::Translation)
          end
        end
        [instance, *localized_instances]
      end
    end
  end

  def initialize(...)
    self.extend(FastGettext::Translation)
  end

  def expanded_base_path
    unlocalized_path = super
    site.default_locale?(locale) ? unlocalized_path : "#{locale}/#{unlocalized_path}"
  end

  def render = site.with_locale(locale) { super }
end
