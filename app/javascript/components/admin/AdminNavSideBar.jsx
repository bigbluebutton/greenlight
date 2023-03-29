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

import {
  AdjustmentsVerticalIcon, Cog8ToothIcon, IdentificationIcon, ServerStackIcon, UsersIcon, VideoCameraIcon, Square3Stack3DIcon,
} from '@heroicons/react/24/outline';
import React from 'react';
import { Nav } from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function AdminNavSideBar() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const location = useLocation();

  return (
    <Nav variant="pills" className="flex-column">
      {/* Todo: Use PermissionChecker */ }
      {(currentUser.permissions.ManageUsers === 'true') && (
      <Nav.Item>
        <Nav.Link
          // Return active if the URL has /users/edit/ to accommodate the EditUser component
          className={`cursor-pointer text-muted ${location?.pathname.includes('/users/edit/') && 'active'}`}
          as={Link}
          to="/admin/users"
          eventKey="users"
        >
          <UsersIcon className="hi-s me-3" />
          { t('admin.manage_users.manage_users') }
        </Nav.Link>
      </Nav.Item>
      )}
      {(currentUser.permissions.ManageRooms === 'true') && (
        <Nav.Item>
          <Nav.Link className="cursor-pointer text-muted" as={Link} to="/admin/server_rooms" eventKey="server_rooms">
            <ServerStackIcon className="hi-s me-3" />
            { t('admin.server_rooms.server_rooms') }
          </Nav.Link>
        </Nav.Item>
      )}
      {(currentUser.permissions.ManageRecordings === 'true') && (
        <Nav.Item>
          <Nav.Link className="cursor-pointer text-muted" as={Link} to="/admin/server_recordings" eventKey="server_recordings">
            <VideoCameraIcon className="hi-s me-3" />
            { t('admin.server_recordings.server_recordings') }
          </Nav.Link>
        </Nav.Item>
      )}
      {(currentUser.permissions.ManageSiteSettings === 'true') && (
        <>
          <Nav.Item>
            <Nav.Link className="cursor-pointer text-muted" as={Link} to="/admin/site_settings" eventKey="site_settings">
              <Cog8ToothIcon className="hi-s me-3" />
              { t('admin.site_settings.site_settings') }
            </Nav.Link>
          </Nav.Item>
          <Nav.Item>
            <Nav.Link className="cursor-pointer text-muted" as={Link} to="/admin/room_configuration" eventKey="room_configuration">
              <AdjustmentsVerticalIcon className="hi-s me-3" />
              { t('admin.room_configuration.room_configuration') }
            </Nav.Link>
          </Nav.Item>
        </>
      )}
      {(currentUser.permissions.ManageRoles === 'true') && (
        <Nav.Item>
          <Nav.Link className="cursor-pointer text-muted" as={Link} to="/admin/roles" eventKey="roles">
            <IdentificationIcon className="hi-s me-3" />
            { t('admin.roles.roles') }
          </Nav.Link>
        </Nav.Item>
      )}
      {(currentUser.isSuperAdmin) && (
        <Nav.Item>
          <Nav.Link className="cursor-pointer text-muted" as={Link} to="/admin/tenants" eventKey="tenants">
            <Square3Stack3DIcon className="hi-s me-3" />
            Manage Tenants
          </Nav.Link>
        </Nav.Item>
      )}
    </Nav>
  );
}
