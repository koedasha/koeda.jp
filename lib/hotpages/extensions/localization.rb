require "fast_gettext"

module Hotpages::Extensions::Localization
  extend Hotpages::Extension

  prepending "Localization::LocalizableConfig", to: "Hotpages::Config"
  prepending "Localization::LocalizablePage", to: "Hotpages::Page"
  prepending "Localization::LocalizablePageFinder", to: "Hotpages::Page::Finder"
  prepending "Localization::LocalizableSite", to: "Hotpages::Site"

  module LocalizableConfig
    module ClassMethods
      def defaults
        pp "Creating default configuration for localization"
        super.tap do |config|
          config.site.add(
            i18n: new(
              locales: %w[ en ],
              default_locale: "en",
              locales_dir: "locales",
              locale_file_format: :yaml
            )
          )
        end
      end
    end
  end

  module LocalizableSite
    GETTEXT_DOMAIN = "hotpages_site"
    Gettext = FastGettext

    def setup
      super
      Gettext.add_text_domain(
        GETTEXT_DOMAIN,
        path: locales_path,
        type: i18n_config.locale_file_format
      )
      Gettext.text_domain = GETTEXT_DOMAIN
      Gettext.available_locales = i18n_config.locales
      Gettext.default_locale = i18n_config.default_locale
    end

    def reload
      super
      Gettext.reload!
    end

    def locales = i18n_config.locales
    def default_locale = i18n_config.default_locale
    def locales_path = root_path.join(i18n_config.locales_dir)
    def default_locale?(locale) = default_locale.to_s == locale.to_s
    def locales_without_default = locales.reject { default_locale?(_1) }
    def current_locale = Gettext.locale
    def current_locale=(locale)
      Gettext.locale = locale
    end
    def with_locale(locale, &block)
      # FIXME: This is a workaround for FastGettext::Storage::NoTextDomainConfigured error
      Gettext.text_domain = GETTEXT_DOMAIN
      Gettext.with_locale(locale, &block)
    end

    private

    def i18n_config = config.site.i18n
  end

  module LocalizablePage
    include FastGettext::Translation

    module ClassMethods
      include Hotpages::Page::Expandable::ClassMethods

      def expand_instances_for(...)
        instances = super
        instances.flat_map do |instance|
          localized_instances = site.locales_without_default.map do |locale|
            instance.dup.tap { _1.locale = locale }
          end
          [ instance, *localized_instances ]
        end
      end
    end

    attr_writer :locale
    def locale = @locale || config.site.i18n.default_locale

    def expanded_base_path(locale: self.locale)
      unlocalized_path = super()

      return unlocalized_path if locale.nil? || site.default_locale?(locale)

      "#{locale}/#{unlocalized_path}"
    end

    def render = site.with_locale(locale) { super }
  end

  module LocalizablePageFinder
    def find(requested_path)
      locale_regexp = %r{\A/?(#{site.locales.join("|")})/}

      if site.locales.any? && requested_path =~ locale_regexp
        locale = $1
        unlocalized_path = "/" + requested_path.sub(locale_regexp, "")
        super(unlocalized_path).tap do |page|
          page.locale = locale if page
        end
      else
        super(requested_path)
      end
    end
  end
end
