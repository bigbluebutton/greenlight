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
import { Container } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import useEnv from '../../hooks/queries/env/useEnv';
import { useAuth } from '../../contexts/auth/AuthProvider';
import Logo from './Logo';
import { getCurrentLanguage } from '../../helpers/LanguageHelper';

const FOOTER_COPY = {
  en: {
    summary: 'Self-hosted virtual classroom software with verified attendance, governance controls, and audit-ready reporting.',
    version: 'Version',
    copyright: (year) => `© ${year} Akademio Live`,
  },
  tr: {
    summary: 'Doğrulanabilir katılım, yönetişim kontrolleri ve denetime hazır raporlama ile self-hosted sanal sınıf yazılımı.',
    version: 'Sürüm',
    copyright: (year) => `© ${year} Akademio Live`,
  },
};

export default function Footer() {
  const { data: env } = useEnv();
  const currentUser = useAuth();
  const { i18n } = useTranslation();
  const isAdmin = currentUser?.role?.name === 'Administrator' || currentUser?.role?.name === 'SuperAdmin';
  const year = new Date().getFullYear();
  const language = getCurrentLanguage(i18n, currentUser?.language || 'en');
  const copy = FOOTER_COPY[language];

  return (
    <footer id="footer" className="footer ak-footer">
      <Container className="ak-footer-grid">
        <div className="ak-footer-brand">
          <Logo size="small" />
          <p>{copy.summary}</p>
        </div>
      </Container>

      <Container className="ak-footer-meta">
        <span>{copy.copyright(year)}</span>
        {isAdmin && env?.VERSION_TAG && <span>{copy.version}: {env.VERSION_TAG}</span>}
      </Container>
    </footer>
  );
}
