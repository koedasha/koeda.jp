require "fast_gettext"

module Hotpages::Extensions::I18n
  extend Hotpages::Extension

  prepending "#{name}::Page", to: "Hotpages::Page"
  prepending "#{name}::PageFinder", to: "Hotpages::PageFinder"
  prepending "#{name}::Site", to: "Hotpages::Site"
  prepending "#{name}::UrlHelper", to: "Hotpages::Helpers::UrlHelper"
  add_helper "#{name}::Helper"

  configure do |config|
    config.site.add(
      i18n: Hotpages::Config.new(
        locales: %w[ en ],
        default_locale: "en",
        locales_directory: "locales",
        locale_file_format: :yaml,
        unlocalized_path_patterns: [ /CNAME\z/, /sitemap.xml\z/, /robot.txt\z/ ]
      )
    )
  end

  module Site
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
    def locales_path = root.join(i18n_config.locales_directory)
    def default_locale?(locale) = default_locale.to_s == locale.to_s
    def locales_without_default = locales.reject { default_locale?(it) }
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

  module Page
    include FastGettext::Translation

    module ClassMethods
      def expand_instances_for(...)
        instances = super
        instances.flat_map do |instance|
          if instance.localizable?
            localized_instances = site.locales_without_default.map do |locale|
              instance.dup.tap { it.locale = locale }
            end
            [ instance, *localized_instances ]
          else
            [ instance ]
          end
        end
      end
    end

    attr_writer :locale
    def locale = @locale || config.site.i18n.default_locale
    def localizable?
      config.site.i18n.unlocalized_path_patterns.none? do |unlocalized_path_pattern|
        expanded_url =~ unlocalized_path_pattern
      end
    end

    def expanded_base_path(locale: self.locale)
      unlocalized_path = super()

      return unlocalized_path if locale.nil? || site.default_locale?(locale)

      "#{locale}/#{unlocalized_path}"
    end

    def render = site.with_locale(locale) { super }
  end

  module PageFinder
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

  module UrlHelper
    private

    def prefix_page_url(url)
      return url unless url.start_with?("/")

      url = if locale && !site.default_locale?(locale)
        "/#{locale}#{url}"
      else
        url
      end

      super(url)
    end
  end

  module Helper
    def locale_selector_tag(
      locales: site.locales,
      default_locale: site.default_locale,
      current_locale: self.locale,
      **options,
      &summary_body
    )
      item_class = options.delete(:item_class)

      tag.div(options) do
        tag.details do
          tag.summary { summary_body ? summary_body.call(current_locale) : current_locale.upcase } +
          tag.ul do
            locales.reject { it == current_locale }.map do |locale|
              tag.li do
                tag.a(
                  href: localized_current_path(locale),
                  class: item_class
                ) do
                  locale.upcase
                end
              end
            end.join
          end
        end
      end
    end

    private

    def localized_current_path(locale)
      base_path = expanded_base_path(locale: nil)
      base_path.delete_suffix!("index")

      # TODO: better handling of base paths
      if site.default_locale?(locale)
        "/#{base_path}"
      else
        "/#{locale}/#{base_path}"
      end
    end
  end
end
