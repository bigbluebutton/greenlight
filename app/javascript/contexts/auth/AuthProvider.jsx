import React, { useContext, useMemo } from 'react';
import PropTypes from 'prop-types';
import useSessions from '../../hooks/queries/rooms/useSessions';

const AuthContext = React.createContext();

// A component that imports the useAuth method will be wrapped with AuthProvider and thus
// should have access to the object(s) in AuthProvider. Is this correct? - SC
export function useAuth() {
  return useContext(AuthContext);
}

export default function AuthProvider({ children }) {
  const { data: session, status, error } = useSessions();

  const currentUser = {
    id: session?.data.current_user?.id,
    name: session?.data.current_user?.name,
    email: session?.data.current_user?.email,
    provider: session?.data.current_user?.provider,
    avatar: session?.data.current_user?.avatar,
    signed_in: session?.data.current_user?.signed_in ?? false,
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
