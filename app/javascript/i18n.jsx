import i18next from 'i18next';
import { initReactI18next } from 'react-i18next';
import HttpApi from 'i18next-http-backend';

i18next
  .use(initReactI18next)
  .use(HttpApi)
  .init({
    fallbackLng: 'en',
    backend: {
      loadPath: '/locales/{{lng}}.json',
      requestOptions: {
        cache: 'no-store', // TODO - samuel: i18n will sometime use the cache translation
      },
    },
    interpolation: {
      escapeValue: false,
    },
  });
export default i18next;
