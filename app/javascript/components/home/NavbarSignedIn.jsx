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

import React, { useMemo } from 'react';
import {
  Button, Nav, Navbar, NavDropdown, Stack,
} from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import { IdentificationIcon, QuestionMarkCircleIcon, StarIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import { ChevronDownIcon } from '@heroicons/react/20/solid';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';
import Avatar from '../users/user/Avatar';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import useRoomConfigValue from '../../hooks/queries/rooms/useRoomConfigValue';

const MODULE_LABELS = {
  en: {
    home: 'Home',
    rooms: 'Rooms',
    sessions: 'Sessions',
    recordings: 'Recordings',
    engagement: 'Engagement',
    files: 'Files',
    reports: 'Reports',
    admin: 'Admin',
  },
  tr: {
    home: 'Ana Sayfa',
    rooms: 'Odalar',
    sessions: 'Oturumlar',
    recordings: 'Kayitlar',
    engagement: 'Etkilesim',
    files: 'Dosyalar',
    reports: 'Raporlar',
    admin: 'Yonetim',
  },
};

function SignedInModuleNav({ modules, mobile = false }) {
  return (
    <Nav className={mobile ? 'ak-signedin-mobile-nav' : 'ak-signedin-nav d-none d-lg-flex'}>
      {modules.map((item) => (
        <Nav.Link
          key={item.key}
          as={Link}
          to={item.to}
          className={`ak-signedin-nav-link ${item.active ? 'is-active' : ''} ${mobile ? 'ak-signedin-mobile-link' : ''}`}
        >
          {item.label}
        </Nav.Link>
      ))}
    </Nav>
  );
}

SignedInModuleNav.propTypes = {
  mobile: PropTypes.bool,
  modules: PropTypes.arrayOf(PropTypes.shape({
    active: PropTypes.bool.isRequired,
    key: PropTypes.string.isRequired,
    label: PropTypes.string.isRequired,
    to: PropTypes.string.isRequired,
  })).isRequired,
};

SignedInModuleNav.defaultProps = {
  mobile: false,
};

export default function NavbarSignedIn({ currentUser }) {
  const { t, i18n } = useTranslation();
  const deleteSession = useDeleteSession({ showToast: true });
  const { data: helpCenter } = useSiteSetting('HelpCenter');
  const { data: recordValue } = useRoomConfigValue('record');
  const location = useLocation();
  const language = (i18n.resolvedLanguage || i18n.language || 'en').toLowerCase().startsWith('tr') ? 'tr' : 'en';
  const labels = MODULE_LABELS[language];

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
  const canViewRecordings = recordValue !== 'false';

  const modules = useMemo(() => {
    const moduleList = [
      { key: 'home', label: labels.home, to: '/home', active: location.pathname === '/home' },
      { key: 'rooms', label: labels.rooms, to: '/rooms', active: location.pathname === '/rooms' || location.pathname.startsWith('/rooms/') },
      { key: 'sessions', label: labels.sessions, to: '/sessions', active: location.pathname === '/sessions' },
    ];

    if (canViewRecordings) {
      moduleList.push({ key: 'recordings', label: labels.recordings, to: '/recordings', active: location.pathname === '/recordings' });
    }

    moduleList.push(
      { key: 'engagement', label: labels.engagement, to: '/engagement', active: location.pathname === '/engagement' },
      { key: 'files', label: labels.files, to: '/files', active: location.pathname === '/files' },
      { key: 'reports', label: labels.reports, to: '/reports', active: location.pathname === '/reports' },
    );

    if (hasAdminAccess) {
      moduleList.push({ key: 'admin', label: labels.admin, to: '/admin', active: location.pathname.startsWith('/admin') });
    }

    return moduleList;
  }, [labels, location.pathname, canViewRecordings, hasAdminAccess]);

  return (
    <>
      <SignedInModuleNav modules={modules} />

      <Navbar.Toggle aria-controls="responsive-navbar-nav" className="border-0 ak-navbar-toggle">
        <Avatar avatar={currentUser?.avatar} size="small" />
      </Navbar.Toggle>
      <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
        <Nav className="d-block d-sm-none text-black px-2">
          <SignedInModuleNav modules={modules} mobile />
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
