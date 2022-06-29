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
  const { data: current_user, status, error } = useSessions();

  const currentUser = {
    id: current_user?.id,
    name: current_user?.name,
    email: current_user?.email,
    provider: current_user?.provider,
    avatar: current_user?.avatar,
    signed_in: current_user?.signed_in ?? false,
    language: current_user?.language,
  };

  const memoizedCurrentUser = useMemo(() => currentUser, [currentUser]);

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
