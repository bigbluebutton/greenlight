import React, { useContext, useMemo } from 'react';
import PropTypes from 'prop-types';
import useSessions from '../../hooks/queries/users/useSessions';

// TODO: Refactor this to use QueryClient context and fetch sessions data from queryCache.

const AuthContext = React.createContext();

// A component that imports the useAuth method will be wrapped with AuthProvider and thus
// should have access to the object(s) in AuthProvider. Is this correct? - SC
export function useAuth() {
  return useContext(AuthContext);
}

export default function AuthProvider({ children }) {
  const { data: currentUser, status, error } = useSessions();

  const user = {
    id: currentUser?.id,
    name: currentUser?.name,
    email: currentUser?.email,
    provider: currentUser?.provider,
    avatar: currentUser?.avatar,
    signed_in: currentUser?.signed_in ?? false,
    language: currentUser?.language,
    permissions: currentUser?.permissions,
    role: currentUser?.role,
    active: currentUser?.active,
  };

  const memoizedCurrentUser = useMemo(() => user, [user]);

  if (status === 'loading') return <p> Loading... </p>;
  if (status === 'error') {
    return (
      <p>{error}</p>
    );
  }

  return (
    <AuthContext.Provider value={memoizedCurrentUser}>
      { children }
    </AuthContext.Provider>
  );
}

AuthProvider.propTypes = {
  children: PropTypes.element.isRequired,
};
