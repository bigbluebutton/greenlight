import React from 'react';
import { Navigate } from 'react-router-dom';
import HomePage from '../components/home/HomePage';
import { useAuth } from '../contexts/auth/AuthProvider';

export default function IndexRouter() {
  const currentUser = useAuth();

  if (currentUser?.signed_in) {
    return <Navigate to="/home" replace />;
  }

  return <HomePage />;
}
