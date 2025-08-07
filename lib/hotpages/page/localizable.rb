require "fast_gettext/translation"

module Hotpages::Page::Localizable
  include Hotpages::Page::Expandable,
          Hotpages::Page::Renderable
  include FastGettext::Translation

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
          instance.dup.tap { _1.locale = locale }
        end
        [instance, *localized_instances]
      end
    end
  end

  def expanded_base_path(locale: self.locale)
    unlocalized_path = super()

    return unlocalized_path if locale.nil? || site.default_locale?(locale)

    "#{locale}/#{unlocalized_path}"
  end

  def render = site.with_locale(locale) { super }
end
