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
import { ChevronDownIcon, GlobeAltIcon } from '@heroicons/react/24/outline';
import { Dropdown, Nav, Navbar } from 'react-bootstrap';
import { useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

const NAV_COPY = {
  en: {
    features: 'Features',
    governance: 'Governance',
    pricing: 'Pricing',
    faq: 'FAQ',
    signIn: 'Sign In',
    bookDemo: 'Book a Demo',
  },
  tr: {
    features: 'Ozellikler',
    governance: 'Yonetisim',
    pricing: 'Fiyatlandirma',
    faq: 'SSS',
    signIn: 'Giris Yap',
    bookDemo: 'Demo Talebi',
  },
};

const LanguageToggle = React.forwardRef(({ children, onClick, className }, ref) => (
  <button
    type="button"
    ref={ref}
    className={className}
    onClick={(event) => {
      event.preventDefault();
      onClick(event);
    }}
  >
    {children}
  </button>
));

LanguageToggle.displayName = 'LanguageToggle';

export default function NavbarNotSignedIn() {
  const location = useLocation();
  const { i18n } = useTranslation();
  const isHome = location.pathname === '/';
  const language = (i18n.resolvedLanguage || i18n.language || 'en').toLowerCase().startsWith('tr') ? 'tr' : 'en';
  const copy = NAV_COPY[language];

  return (
    <>
      <Navbar.Toggle aria-controls="navbar-menu" className="border-0 ak-navbar-toggle" />

      <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
        <Nav className="d-block d-sm-none text-black px-3 py-2">
          {isHome && (
            <>
              <Nav.Link href="/#features">{copy.features}</Nav.Link>
              <Nav.Link href="/#security">{copy.governance}</Nav.Link>
              <Nav.Link href="/#pricing">{copy.pricing}</Nav.Link>
              <Nav.Link href="/#faq">{copy.faq}</Nav.Link>
            </>
          )}
          <div className="ak-lang-mobile-group">
            <button type="button" className={`ak-lang-mobile-option ${language === 'en' ? 'active' : ''}`} onClick={() => { i18n.changeLanguage('en'); }}>
              EN
            </button>
            <button type="button" className={`ak-lang-mobile-option ${language === 'tr' ? 'active' : ''}`} onClick={() => { i18n.changeLanguage('tr'); }}>
              TR
            </button>
          </div>
          <Nav.Link href="/signin" className="ak-mobile-signin-link">{copy.signIn}</Nav.Link>
          <a href="/#demo-form" className="btn btn-brand ak-book-demo-btn ak-book-demo-btn-mobile">{copy.bookDemo}</a>
        </Nav>
      </Navbar.Collapse>

      <div className="justify-content-end d-none d-sm-flex align-items-center ak-navbar-shell">
        {isHome && (
          <Nav className="ak-navbar-links">
            <Nav.Link href="/#features">{copy.features}</Nav.Link>
            <Nav.Link href="/#security">{copy.governance}</Nav.Link>
            <Nav.Link href="/#pricing">{copy.pricing}</Nav.Link>
            <Nav.Link href="/#faq">{copy.faq}</Nav.Link>
          </Nav>
        )}

        <Dropdown align="end" className="ak-lang-dropdown-shell">
          <Dropdown.Toggle as={LanguageToggle} className="ak-lang-toggle ak-lang-dropdown-toggle" id="ak-lang-dropdown-toggle">
            <GlobeAltIcon className="ak-lang-icon" aria-hidden="true" />
            <span>{language.toUpperCase()}</span>
            <ChevronDownIcon className="ak-lang-chevron" aria-hidden="true" />
          </Dropdown.Toggle>
          <Dropdown.Menu className="ak-lang-dropdown-menu">
            <Dropdown.Item active={language === 'en'} onClick={() => { i18n.changeLanguage('en'); }}>
              <span>English</span>
              <small>EN</small>
            </Dropdown.Item>
            <Dropdown.Item active={language === 'tr'} onClick={() => { i18n.changeLanguage('tr'); }}>
              <span>Turkce</span>
              <small>TR</small>
            </Dropdown.Item>
          </Dropdown.Menu>
        </Dropdown>
        <a href="/signin" className="ak-signin-link">{copy.signIn}</a>
        <a href="/#demo-form" className="btn btn-brand ak-book-demo-btn">{copy.bookDemo}</a>
      </div>
    </>
  );
}
