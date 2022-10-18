import React from 'react';
import { Navigate, Outlet, useSearchParams } from 'react-router-dom';
import { useAuth } from '../contexts/auth/AuthProvider';

export default function UnauthenticatedOnly() {
  const currentUser = useAuth();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('location') || '/';

  if (currentUser.signed_in) {
    return <Navigate to={redirect} replace />;
  }

  return <Outlet />;
}
