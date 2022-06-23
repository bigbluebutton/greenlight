import React from 'react';
import { useAuth } from '../../contexts/auth/AuthProvider';
import ProtectedRoute from './ProtectedRoute';

export default function ActivatedOnly() {
  const { active } = useAuth();

  return <ProtectedRoute redirectTo="/verify_account" when={active} />;
}
