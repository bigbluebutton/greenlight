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
  Button, Dropdown, Nav, Navbar, NavDropdown, Stack,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { ChevronDownIcon } from '@heroicons/react/20/solid';
import {
  GlobeAltIcon,
  IdentificationIcon,
  QuestionMarkCircleIcon,
  StarIcon,
} from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';
import Avatar from '../users/user/Avatar';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import {
  getCurrentLanguage,
  normalizeLanguageCode,
  persistLanguage,
} from '../../helpers/LanguageHelper';

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

export default function NavbarSignedIn({ currentUser }) {
  const { t, i18n } = useTranslation();
  const deleteSession = useDeleteSession({ showToast: true });
  const { data: helpCenter } = useSiteSetting('HelpCenter');
  const language = getCurrentLanguage(i18n, currentUser?.language || 'en');

  const changeLanguage = (nextLanguage) => {
    const normalizedLanguage = normalizeLanguageCode(nextLanguage);
    persistLanguage(normalizedLanguage);
    i18n.changeLanguage(normalizedLanguage);
  };

  const adminAccess = () => {
    const { permissions } = currentUser;
    const {
      ManageUsers, ManageRooms, ManageRecordings, ManageSiteSettings, ManageRoles,
    } = permissions;

    if (ManageUsers === 'true'
      || ManageRooms === 'true'
      || ManageRecordings === 'true'
      || ManageSiteSettings === 'true'
      || ManageRoles === 'true'
      || currentUser?.isSuperAdmin) {
      return true;
    }

    return false;
  };

  const hasAdminAccess = adminAccess();

  return (
    <>
      <Navbar.Toggle aria-controls="navbar-menu" className="border-0 ak-navbar-toggle">
        <Avatar avatar={currentUser?.avatar} size="small" />
      </Navbar.Toggle>
      <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
        <Nav className="d-block d-sm-none text-black px-2">
          <div className="ak-lang-mobile-group">
            <button type="button" className={`ak-lang-mobile-option ${language === 'en' ? 'active' : ''}`} onClick={() => { changeLanguage('en'); }}>
              EN
            </button>
            <button type="button" className={`ak-lang-mobile-option ${language === 'tr' ? 'active' : ''}`} onClick={() => { changeLanguage('tr'); }}>
              TR
            </button>
          </div>
          <NavDropdown.Divider />
          <Nav.Link eventKey={1} as={Link} to="/profile">
            <IdentificationIcon className="hi-s me-3" />
            {t('user.profile.profile')}
          </Nav.Link>
          {
            helpCenter
            && (
              <Nav.Link eventKey={2} href={helpCenter} target="_blank">
                <QuestionMarkCircleIcon className="hi-s me-3" />
                {t('help_center')}
              </Nav.Link>
            )
          }
          {
            hasAdminAccess
            && (
              <Nav.Link eventKey={3} as={Link} to="/admin">
                <StarIcon className="hi-s me-3 mb-1" />
                { t('admin.admin_panel') }
              </Nav.Link>
            )
          }
          <NavDropdown.Divider />
          <Button
            onClick={deleteSession.mutate}
            variant="brand"
            className="btn btn-sm mt-2 mb-3 py-2 w-100"
          >{t('authentication.sign_out')}
          </Button>
        </Nav>
      </Navbar.Collapse>

      <div className="justify-content-end d-none d-sm-flex align-items-center ak-navbar-shell">
        <Dropdown align="end" className="ak-lang-dropdown-shell">
          <Dropdown.Toggle as={LanguageToggle} className="ak-lang-toggle ak-lang-dropdown-toggle" id="ak-app-lang-dropdown-toggle">
            <GlobeAltIcon className="ak-lang-icon" aria-hidden="true" />
            <span>{language.toUpperCase()}</span>
            <ChevronDownIcon className="ak-lang-chevron" aria-hidden="true" />
          </Dropdown.Toggle>
          <Dropdown.Menu className="ak-lang-dropdown-menu">
            <Dropdown.Item active={language === 'en'} onClick={() => { changeLanguage('en'); }}>
              <span>English</span>
              <small>EN</small>
            </Dropdown.Item>
            <Dropdown.Item active={language === 'tr'} onClick={() => { changeLanguage('tr'); }}>
              <span>Türkçe</span>
              <small>TR</small>
            </Dropdown.Item>
          </Dropdown.Menu>
        </Dropdown>

        <div className="justify-content-end d-none d-sm-block">
          <NavDropdown
            title={(
              <Stack direction="horizontal" gap={2}>
                <Avatar avatar={currentUser?.avatar} size="small" />
                <span className="ms-1">{currentUser?.name}</span>
                <ChevronDownIcon id="chevron-profile" className="hi-s text-muted" />
              </Stack>
            )}
            id="nav-user-dropdown"
            className="d-inline-block"
            align="end"
          >

            <NavDropdown.Item as={Link} to="/profile">
              <IdentificationIcon className="hi-s me-3" />
              { t('user.profile.profile') }
            </NavDropdown.Item>
            {
              helpCenter
              && (
                <NavDropdown.Item href={helpCenter} target="_blank">
                  <QuestionMarkCircleIcon className="hi-s me-3" />
                  {t('help_center')}
                </NavDropdown.Item>
              )
            }
            {
              hasAdminAccess
              && (
                <NavDropdown.Item as={Link} to="/admin">
                  <StarIcon className="hi-s me-3 mb-1" />
                  { t('admin.admin_panel') }
                </NavDropdown.Item>
              )
            }
            <NavDropdown.Divider />
            <div className="px-2">
              <Button onClick={deleteSession.mutate} variant="brand" className="btn btn-sm w-100 my-2">{t('authentication.sign_out')}</Button>
            </div>
          </NavDropdown>
        </div>
      </div>
    </>
  );
}

NavbarSignedIn.propTypes = {
  currentUser: PropTypes.shape({
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    isSuperAdmin: PropTypes.bool.isRequired,
    permissions: PropTypes.shape({
      ManageUsers: PropTypes.string.isRequired,
      ManageRooms: PropTypes.string.isRequired,
      ManageRecordings: PropTypes.string.isRequired,
      ManageSiteSettings: PropTypes.string.isRequired,
      ManageRoles: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
};
