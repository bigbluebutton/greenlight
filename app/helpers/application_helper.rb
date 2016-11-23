module ApplicationHelper
  def client_translations
    locale = I18n.locale
    if locale.length < 4
      fallback_locale = I18n.fallbacks[locale].second
    end

    if fallback_locale
      I18n.locale = fallback_locale
      translations = I18n.t('.')
      I18n.locale = locale
    else
      translations = I18n.t('.')
    end
    translations[:client]
  end

  def omniauth_providers_configured(provider = nil)
    if provider
      Rails.configuration.send("omniauth_#{provider}")
    else
      providers = []
      Rails.configuration.providers.each do |provider|
        providers.push(provider) if Rails.configuration.send("omniauth_#{provider}")
      end
      providers
    end
  end
end
