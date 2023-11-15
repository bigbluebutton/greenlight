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
import { Navigate, Outlet, useMatch } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import { useAuth } from '../contexts/auth/AuthProvider';
import useDeleteSession from '../hooks/mutations/sessions/useDeleteSession';

export default function AuthenticatedOnly() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const roomsMatch = useMatch('/rooms/:friendlyId');
  const superAdminMatch = useMatch('/admin/*');
  const deleteSession = useDeleteSession({ showToast: false });

  // User is either pending or banned
  if (currentUser.signed_in && (currentUser.status !== 'active' || !currentUser.verified)) {
    deleteSession.mutate();

    if (currentUser.status === 'pending') {
      toast.error(t('toast.error.users.pending'));
    } else if (currentUser.status === 'banned') {
      toast.error(t('toast.error.users.banned'));
    } else {
      toast.error(t('toast.error.signin_required'));
    }
  }

  // Custom logic to redirect from Rooms page to join page if the user isn't signed in
  if (!currentUser.signed_in && roomsMatch) {
    return <Navigate to={`${roomsMatch.pathnameBase}/join`} />;
  }

  if (currentUser.signed_in && currentUser.isSuperAdmin && !superAdminMatch) {
    return <Navigate to="/admin/users" />;
  }

  if (!currentUser.signed_in) {
    toast.error(t('toast.error.signin_required'));
    return <Navigate to="/" />;
  }

  return <Outlet />;
}
