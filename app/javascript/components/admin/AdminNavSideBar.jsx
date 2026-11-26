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
import { ChevronDownIcon } from '@heroicons/react/20/solid';
import React from 'react';
import { Dropdown, Nav } from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function AdminNavSideBar() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const location = useLocation();
  const { permissions } = currentUser;

  // Todo: Use PermissionChecker
  const sections = [
    {
      key: 'users', to: '/admin/users', Icon: UsersIcon, label: t('admin.manage_users.manage_users'), allowed: permissions.ManageUsers === 'true',
    },
    {
      key: 'server_rooms',
      to: '/admin/server_rooms',
      Icon: ServerStackIcon,
      label: t('admin.server_rooms.server_rooms'),
      allowed: permissions.ManageRooms === 'true',
    },
    {
      key: 'server_recordings',
      to: '/admin/server_recordings',
      Icon: VideoCameraIcon,
      label: t('admin.server_recordings.server_recordings'),
      allowed: permissions.ManageRecordings === 'true',
    },
    {
      key: 'site_settings',
      to: '/admin/site_settings',
      Icon: Cog8ToothIcon,
      label: t('admin.site_settings.site_settings'),
      allowed: permissions.ManageSiteSettings === 'true',
    },
    {
      key: 'room_configuration',
      to: '/admin/room_configuration',
      Icon: AdjustmentsVerticalIcon,
      label: t('admin.room_configuration.room_configuration'),
      allowed: permissions.ManageSiteSettings === 'true',
    },
    {
      key: 'roles', to: '/admin/roles', Icon: IdentificationIcon, label: t('admin.roles.roles'), allowed: permissions.ManageRoles === 'true',
    },
    {
      key: 'tenants', to: '/admin/tenants', Icon: Square3Stack3DIcon, label: 'Manage Tenants', allowed: currentUser.isSuperAdmin,
    },
  ].filter((section) => section.allowed);

  // Edit pages live below their section, e.g. /admin/users/edit/:id.
  const current = sections.find((section) => location?.pathname.startsWith(section.to));

  return (
    <>
      {/* Sidebar list, from xl */}
      <Nav variant="pills" className="flex-column d-none d-xl-flex">
        {sections.map(({
          key, to, Icon, label,
        }) => (
          <Nav.Item key={key}>
            <Nav.Link className="cursor-pointer text-muted" as={Link} to={to} eventKey={key} active={key === current?.key}>
              <Icon className="hi-s me-3" />
              { label }
            </Nav.Link>
          </Nav.Item>
        ))}
      </Nav>

      {/* Dropdown, below xl. The pill classes style the toggle like the active entry of the list. */}
      <nav className="section-nav-dropdown nav-pills d-xl-none" aria-label={t('admin.admin_panel')}>
        <Dropdown>
          <Dropdown.Toggle as="button" type="button" className="nav-link active w-100 d-flex align-items-center text-start">
            {current && <current.Icon className="hi-s me-3" aria-hidden="true" />}
            { current?.label }
            <ChevronDownIcon className="hi-s ms-auto" aria-hidden="true" />
          </Dropdown.Toggle>
          <Dropdown.Menu>
            {sections.map(({
              key, to, Icon, label,
            }) => (
              <Dropdown.Item
                key={key}
                as={Link}
                to={to}
                active={key === current?.key}
                aria-current={key === current?.key ? 'page' : undefined}
              >
                <Icon className="hi-s me-3" aria-hidden="true" />
                { label }
              </Dropdown.Item>
            ))}
          </Dropdown.Menu>
        </Dropdown>
      </nav>
    </>
  );
}
