require "fast_gettext"

module Hotpages::Site::Localizable
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
