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
import { useTranslation } from 'react-i18next';
import { Container } from 'react-bootstrap';
import useEnv from '../../hooks/queries/env/useEnv';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Footer() {
  const { t } = useTranslation();
  const { data: env } = useEnv();
  const { data: links } = useSiteSetting(['Terms', 'PrivacyPolicy']);

  return (
    <footer id="footer" className="footer background-whitesmoke text-center">
      <Container id="footer-container" className="py-3">
        <a href="https://docs.bigbluebutton.org/greenlight_v3/gl3-install.html" target="_blank" rel="noreferrer">Greenlight</a>
        <span className="text-muted"> {env?.VERSION_TAG} </span>
        { links?.Terms
          && (
            <a className="ps-3" href={links?.Terms} target="_blank" rel="noreferrer">
              { t('admin.site_settings.administration.terms') }
            </a>
          )}
        { links?.PrivacyPolicy
          && (
            <a className="ps-3" href={links?.PrivacyPolicy} target="_blank" rel="noreferrer">
              { t('admin.site_settings.administration.privacy_policy') }
            </a>
          )}
      </Container>
    </footer>
  );
}
