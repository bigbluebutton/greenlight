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
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function AdminPanel() {
  const currentUser = useAuth();

  const navigateTo = () => {
    const { permissions } = currentUser;
    const {
      ManageUsers, ManageRooms, ManageRecordings, ManageSiteSettings, ManageRoles,
    } = permissions;

    if (ManageUsers === 'true') {
      return '/admin/users';
    }

    if (ManageRooms === 'true') {
      return '/admin/server_rooms';
    }

    if (ManageRecordings === 'true') {
      return '/admin/server_recordings';
    }

    if (ManageSiteSettings === 'true') {
      return '/admin/site_settings';
    }

    if (ManageRoles === 'true') {
      return '/admin/roles';
    }

    if (currentUser?.isSuperAdmin) {
      return '/admin/tenants';
    }

    return '/';
  };

  return (
    <Navigate to={navigateTo()} replace />
  );
}
