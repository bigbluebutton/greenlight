import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/auth/AuthProvider';

export default function IndexRouter() {
  const currentUser = useAuth();

  if (currentUser?.signed_in) {
    return <Navigate to="/home" replace />;
  }

  return <Navigate to="/signin" replace />;
}
