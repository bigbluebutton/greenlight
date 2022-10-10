import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/auth/AuthProvider';

export default function AuthenticatedAndActiveOnly() {
  const currentUser = useAuth();

  if (!currentUser.signed_in) {
    return <Navigate to="/signin" />;
  }

  if (!currentUser.active) {
    return <Navigate to="/verify_account" />;
  }

  return <Outlet />;
}
