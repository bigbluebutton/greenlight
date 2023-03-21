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
import HttpApi from 'i18next-http-backend';
import { useMemo } from 'react';
import useEnv from './queries/env/useEnv';

const inferFallbackLangs = (locale) => {
  const fallbacks = [];

  if (locale?.indexOf('-') > -1) {
    fallbacks.push(locale.split('-')[0]);
  }

  fallbacks.push('en');
  return fallbacks;
};

export default function useI18n() {
  const envAPI = useEnv();

  const relativeUrlRoot = envAPI.data?.RELATIVE_URL_ROOT || '';

  return useMemo(() => {
    const i18n = i18next.createInstance();

    i18n.use(HttpApi)
      .init({
        backend: {
          loadPath: `${relativeUrlRoot}/api/v1/locales/{{lng}}.json`,
        },
        load: 'currentOnly',
        fallbackLng: inferFallbackLangs,
      });

    return i18n;
  }, [relativeUrlRoot]);
}
