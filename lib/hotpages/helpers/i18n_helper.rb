module Hotpages::Helpers::I18nHelper
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
          locales.reject { _1 == current_locale }.map do |locale|
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
