import React, { useContext, useMemo } from 'react';
import { useQuery } from 'react-query';

const AuthContext = React.createContext();

// A component that imports the useAuth method will be wrapped with AuthContext and thus
// should have access to the object(s) in AuthProvider. Is this correct? - SC
export function useAuth() {
  return useContext(AuthContext);
}

export default function AuthProvider({ children }) {
  async function fetchCurrentUser() {
    const response = await fetch('/api/v1/sessions/signed_in');
    if (!response.ok) throw new Error('User is not signed in.');
    return response.json();
  }

  const { data: session, status, error } = useQuery('current_user', fetchCurrentUser);

  const currentUser = {
    name: session?.current_user?.name,
    email: session?.current_user?.email,
    provider: session?.current_user?.provider,
    signed_in: session?.signed_in ?? false,
  };

  // ESlint is suggesting to useMemo so currentUser is not changed every render. To be reviewed - SC
  const memoizedCurrentUser = useMemo(() => currentUser, [currentUser]);

  if (status === 'loading') return <p> Loading... </p>
  if (status === 'error') return <p> {error} </p>

  return (
    <AuthContext.Provider value={memoizedCurrentUser}>
      { children }
    </AuthContext.Provider>
  );
}
