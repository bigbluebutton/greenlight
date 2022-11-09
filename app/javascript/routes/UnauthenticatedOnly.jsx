import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/auth/AuthProvider';

export default function UnauthenticatedOnly() {
  const currentUser = useAuth();

  if (currentUser.signed_in) {
    return <Navigate to="/" replace />;
  }

  return <Outlet />;
}