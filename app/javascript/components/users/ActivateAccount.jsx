import React, { useEffect } from 'react';
import { Navigate, useParams } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useActivateAccount from '../../hooks/mutations/account_activation/useActivateAccount';
import Spinner from '../shared/stylings/Spinner';

export default function ActivateAccount() {
  const { active } = useAuth();
  const { token } = useParams();
  const { activate, isLoading } = useActivateAccount(token);

  useEffect(() => {
    activate();
  }, []);

  if (!active || isLoading) return <Spinner />;

  return <Navigate to="/rooms" replace />;
}
