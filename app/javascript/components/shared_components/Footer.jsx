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
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import { useAuth } from '../../contexts/auth/AuthProvider';
import Logo from './Logo';

const FOOTER_COPY = {
  en: {
    summary: 'Self-hosted virtual classroom software with verified attendance, governance controls, and audit-ready reporting.',
    product: 'Platform',
    productLinks: [
      ['Features', '/#features'],
      ['Governance', '/#security'],
      ['Pricing', '/#pricing'],
      ['FAQ', '/#faq'],
    ],
    resources: 'Operations',
    resourceLinks: [
      ['Operations Workspace', '/rooms?view=overview'],
      ['Learning Analytics', '/learning-analytics-dashboard/'],
      ['Scheduling', '/rooms?view=schedule'],
      ['Sign In', '/signin'],
    ],
    legal: 'Legal',
    version: 'Version',
    copyright: (year) => `© ${year} Akademio Live`,
  },
  tr: {
    summary: 'Dogrulanabilir katilim, yonetisim kontrolleri ve denetime hazir raporlama ile self-hosted sanal sinif yazilimi.',
    product: 'Platform',
    productLinks: [
      ['Ozellikler', '/#features'],
      ['Yonetisim', '/#security'],
      ['Fiyatlandirma', '/#pricing'],
      ['SSS', '/#faq'],
    ],
    resources: 'Operasyonlar',
    resourceLinks: [
      ['Operasyon Alani', '/rooms?view=overview'],
      ['Ogrenim Analitigi', '/learning-analytics-dashboard/'],
      ['Planlama', '/rooms?view=schedule'],
      ['Giris Yap', '/signin'],
    ],
    legal: 'Yasal',
    version: 'Surum',
    copyright: (year) => `© ${year} Akademio Live`,
  },
};

export default function Footer() {
  const { data: env } = useEnv();
  const { data: links } = useSiteSetting(['Terms', 'PrivacyPolicy']);
  const currentUser = useAuth();
  const { i18n } = useTranslation();
  const isAdmin = currentUser?.role?.name === 'Administrator' || currentUser?.role?.name === 'SuperAdmin';
  const year = new Date().getFullYear();
  const language = (i18n.resolvedLanguage || i18n.language || currentUser?.language || 'en').toLowerCase().startsWith('tr') ? 'tr' : 'en';
  const copy = FOOTER_COPY[language];

  return (
    <footer id="footer" className="footer ak-footer">
      <Container className="ak-footer-grid">
        <div className="ak-footer-brand">
          <Logo size="small" />
          <p>{copy.summary}</p>
        </div>

        <div className="ak-footer-columns">
          <div className="ak-footer-column">
            <span className="ak-footer-heading">{copy.product}</span>
            <nav className="ak-footer-link-list">
              {copy.productLinks.map(([label, href]) => (
                <a key={label} href={href}>{label}</a>
              ))}
            </nav>
          </div>

          <div className="ak-footer-column">
            <span className="ak-footer-heading">{copy.resources}</span>
            <nav className="ak-footer-link-list">
              {copy.resourceLinks.map(([label, href]) => (
                <a key={label} href={href}>{label}</a>
              ))}
            </nav>
          </div>

          <div className="ak-footer-column">
            <span className="ak-footer-heading">{copy.legal}</span>
            <nav className="ak-footer-link-list">
              {links?.Terms && <a href={links.Terms} target="_blank" rel="noreferrer">Terms</a>}
              {links?.PrivacyPolicy && <a href={links.PrivacyPolicy} target="_blank" rel="noreferrer">Privacy Policy</a>}
            </nav>
          </div>
        </div>
      </Container>

      <Container className="ak-footer-meta">
        <span>{copy.copyright(year)}</span>
        {isAdmin && env?.VERSION_TAG && <span>{copy.version}: {env.VERSION_TAG}</span>}
      </Container>
    </footer>
  );
}
