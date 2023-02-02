import i18next from 'i18next';
import { initReactI18next } from 'react-i18next';
import HttpApi from 'i18next-http-backend';

i18next
  .use(initReactI18next)
  .use(HttpApi)
  .init({
    backend: {
      loadPath: '/api/v1/locales/{{lng}}.json',
    },
    load: 'currentOnly',
    fallbackLng: (locale) => {
      const fallbacks = [];
      if (locale?.indexOf('-') > -1) {
        fallbacks.push(locale.split('-')[0]);
      }
      fallbacks.push('en');
      return fallbacks;
    },
  });
export default i18next;
