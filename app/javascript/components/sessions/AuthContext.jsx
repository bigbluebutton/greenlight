import React, { useContext, useMemo } from 'react';
import useSessions from '../../hooks/queries/sessions/useSessions';

const AuthContext = React.createContext();

export function useAuth() {
  return useContext(AuthContext);
}

export default function AuthProvider({ children }) {

  const { data: session, status, error } = useSessions();

  const currentUser = {
    name: session?.current_user?.name,
    email: session?.current_user?.email,
    provider: session?.current_user?.provider,
    signed_in: session?.signed_in ?? false,
  };

  const memoizedCurrentUser = useMemo(() => currentUser, [currentUser]);

  if (status === 'loading') return <p> Loading... </p>
  if (status === 'error') return <p> {error} </p>

  return (
    <AuthContext.Provider value={memoizedCurrentUser}>
      { children }
    </AuthContext.Provider>
  );
}
