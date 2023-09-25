// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import i18next from 'i18next';
import { initReactI18next } from 'react-i18next';
import HttpApi from 'i18next-http-backend';

i18next
  .use(initReactI18next)
  .use(HttpApi)
  .init({
    backend: {
      loadPath: `${process.env.RELATIVE_URL_ROOT}/api/v1/locales/{{lng}}.json`,
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
