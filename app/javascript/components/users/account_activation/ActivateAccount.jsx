import React, { useEffect } from 'react';
import { Navigate, useParams } from 'react-router-dom';
import useActivateAccount from '../../../hooks/mutations/users/useActivateAccount';

export default function ActivateAccount() {
  const { token } = useParams();
  const activateAccountAPI = useActivateAccount(token);

  useEffect(() => {
    activateAccountAPI.mutate();
  }, []);

  if (activateAccountAPI.isIdle || activateAccountAPI.isLoading) return null;

  return <Navigate to="/" replace />;
}
