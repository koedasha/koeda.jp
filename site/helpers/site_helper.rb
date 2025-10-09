module SiteHelper
  def change_locale_from_default_to_user_language(
    locales: site.locales,
    default_locale: site.default_locale,
    fallback_locale: "en",
    current_locale: self.locale
  )
    tag.script do
      <<~JS
        (function changeLocaleFromDefaultToUserLanguage() {
          const params = new URLSearchParams(window.location.search)
          // Return if user has selected a locale
          if (params.get("locale_selected")) return
          // Return if already changed locale
          if (params.get("locale_changed")) return

          const currentLocale = "#{current_locale}"
          const userLang = navigator.language || navigator.userLanguage;
          if (userLang.startsWith(currentLocale)) return

          const availableLocales = #{locales.to_json}
          const matchedLocale = availableLocales.find(locale => userLang.startsWith(locale))
          const path = window.location.pathname

          if (matchedLocale) {
            if (matchedLocale !== "#{default_locale}") {
              window.location.href = `/${matchedLocale}${path}?locale_changed=1`;
            }
          } else {
            if ("#{default_locale}" !== "#{fallback_locale}") {
              window.location.href = `/#{fallback_locale}${path}?locale_changed=1`;
            }
          }
        })()
      JS
    end
  end
end
