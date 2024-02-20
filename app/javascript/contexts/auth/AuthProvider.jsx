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

import React, { useContext, useMemo } from 'react';
import PropTypes from 'prop-types';
import useSessions from '../../hooks/queries/users/useSessions';

// TODO: Amir - Refactor this to use QueryClient context and fetch sessions data from queryCache.

const AuthContext = React.createContext();

// A component that imports the useAuth method will be wrapped with AuthProvider and thus
// should have access to the object(s) in AuthProvider. Is this correct? - SC
export function useAuth() {
  return useContext(AuthContext);
}

export default function AuthProvider({ children }) {
  const { isLoading, data: currentUser } = useSessions();

  const user = {
    id: currentUser?.id,
    name: currentUser?.name,
    email: currentUser?.email,
    provider: currentUser?.provider,
    avatar: currentUser?.avatar,
    signed_in: currentUser?.signed_in ?? false,
    language: currentUser?.language || currentUser?.default_locale || window.navigator.language || window.navigator.userLanguage,
    permissions: currentUser?.permissions,
    role: currentUser?.role,
    verified: currentUser?.verified,
    status: currentUser?.status,
    external_account: currentUser?.external_account,
    stateChanging: false,
    isSuperAdmin: currentUser?.super_admin,
    terms: currentUser?.terms,
    marketing: currentUser?.marketing,
  };

  const memoizedCurrentUser = useMemo(() => user, [user]);

  if (isLoading) return null;

  return (
    <AuthContext.Provider value={memoizedCurrentUser}>
      { children }
    </AuthContext.Provider>
  );
}

AuthProvider.propTypes = {
  children: PropTypes.element.isRequired,
};
