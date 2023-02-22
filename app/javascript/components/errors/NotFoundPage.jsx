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

import React from 'react';
import {
  Card, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Logo from '../shared_components/Logo';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function NotFoundPage() {
  const { t } = useTranslation();

  // Needed for Route Errors
  const { data: brandColor } = useSiteSetting('PrimaryColor');
  document.documentElement.style.setProperty('--brand-color', brandColor);

  return (
    <div className="pt-lg-5">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-3 mx-auto p-4 border-0 card-shadow">
        <Stack direction="vertical" className="py-3">
          <h1><strong>404</strong></h1>
          <h3>{t('not_found_error_page.title')}</h3>
        </Stack>
        <span className="mb-3">{ t('not_found_error_page.message') }</span>
        <ButtonLink to="/" variant="brand" className="btn btn-lg mt-2">
          {t('return_home')}
        </ButtonLink>
      </Card>
    </div>
  );
}
