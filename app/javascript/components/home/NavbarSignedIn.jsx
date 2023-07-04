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
  Button, Nav, Navbar, NavDropdown, Stack,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import {
  IdentificationIcon, QuestionMarkCircleIcon, StarIcon, BuildingLibraryIcon,
} from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import { ChevronDownIcon } from '@heroicons/react/20/solid';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';
import Avatar from '../users/user/Avatar';

export default function NavbarSignedIn({ currentUser }) {
  const { t } = useTranslation();
  const deleteSession = useDeleteSession({ showToast: true });

  const adminAccess = () => {
    const { permissions } = currentUser;
    const {
      ManageUsers, ManageRooms, ManageRecordings, ManageSiteSettings, ManageRoles,
    } = permissions;

    // Todo: Use PermissionChecker.
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

  return (
    <>
      {/* Mobile Navbar Toggle - Hidden on Desktop */}
      <Navbar.Toggle aria-controls="responsive-navbar-nav" className="border-0">
        <Avatar avatar={currentUser?.avatar} size="small" />
      </Navbar.Toggle>
      <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
        <Nav className="d-block d-sm-none text-black px-2">
          <NavDropdown.Item href="https://www.lessons80.com">
            <BuildingLibraryIcon className="hi-s me-3" />
            {t('dashboard')}
          </NavDropdown.Item>
          <Nav.Link eventKey={1} as={Link} to="/profile">
            <IdentificationIcon className="hi-s me-3" />
            {t('user.profile.profile')}
          </Nav.Link>
          <Nav.Link eventKey={2} href="https://www.lessons80.com/help">
            <QuestionMarkCircleIcon className="hi-s me-3" />
            {t('help_center')}
          </Nav.Link>
          {
            adminAccess()
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

      {/* Desktop User Dropdown - Hidden on Mobile */}
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

          <NavDropdown.Item href="https://www.lessons80.com">
            <BuildingLibraryIcon className="hi-s me-3" />
            {t('dashboard')}
          </NavDropdown.Item>
          <NavDropdown.Item as={Link} to="/profile">
            <IdentificationIcon className="hi-s me-3" />
            { t('user.profile.profile') }
          </NavDropdown.Item>
          <NavDropdown.Item href="https://www.lessons80.com/help">
            <QuestionMarkCircleIcon className="hi-s me-3" />
            {t('help_center')}
          </NavDropdown.Item>
          {
            adminAccess()
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
