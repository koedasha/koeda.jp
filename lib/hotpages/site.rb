require "forwardable"
require "pathname"
require "fast_gettext"

class Hotpages::Site
  extend Forwardable

  class << self
    def config = @config ||= Hotpages.config
  end

  attr_reader :config

  def initialize
    @config = self.class.config
    @loader = Loader.new(site: self)
    @generator = Generator.new(site: self)
  end

  def setup
    loader.setup
    super
  end

  def teardown
    loader.unload
    loader.unregister
  end

  delegate %i[ reload ] => :loader
  delegate %i[ generate generating? ] => :generator

  def pages_namespace_module(ns_name = config.site.pages_namespace)
     Object.const_defined?(ns_name) ? Object.const_get(ns_name)
                                    : Object.const_set(ns_name, Module.new)
  end

  module Paths
    extend Forwardable

    delegate %i[
      root dist_dir models_dir helpers_dir layouts_dir assets_dir pages_dir shared_dir
    ] => :site_config

    def root_path = @root_path ||= Pathname.new(root)
    def dist_path = root_path.join(dist_dir)
    def models_path = root_path.join(models_dir)
    def helpers_path = root_path.join(helpers_dir)
    def layouts_path = root_path.join(layouts_dir)
    def assets_path = root_path.join(assets_dir)
    def pages_path = root_path.join(pages_dir)
    def shared_path = root_path.join(shared_dir)

    private

    def site_config = config.site
  end
  include Paths

  module Localizable
    GETTEXT_DOMAIN = "hotpages_site"
    Gettext = FastGettext

    def setup
      Gettext.add_text_domain(
        GETTEXT_DOMAIN,
        path: locales_path,
        type: i18n_config.locale_file_format
      )
      Gettext.text_domain = GETTEXT_DOMAIN
      Gettext.available_locales = i18n_config.locales
    end

    def locales = i18n_config.locales
    def locales_path = root_path.join(i18n_config.locales_dir)
    def default_locale?(locale) = i18n_config.default_locale.to_s == locale.to_s
    def locales_without_default = locales.reject { default_locale?(_1) }
    def current_locale = Gettext.locale
    def current_locale=(locale)
      Gettext.locale = locale
    end
    def with_locale(locale, &block)
      # FIXME: This is a workaround for FastGettext::Storage::NoTextDomainConfigured error
      Gettext.text_domain = GETTEXT_DOMAIN
      previous_locale = current_locale
      self.current_locale = locale
      yield
    ensure
      self.current_locale = previous_locale
    end

    private

    def i18n_config = config.site.i18n
  end
  include Localizable

  private

  attr_accessor :loader, :generator
end
