import React, { useEffect } from 'react';
import { Navigate, useParams } from 'react-router-dom';
import useActivateAccount from '../../../hooks/mutations/users/useActivateAccount';
import Spinner from '../../shared_components/utilities/Spinner';

export default function ActivateAccount() {
  const { token } = useParams();
  const activateAccountAPI = useActivateAccount(token);

  useEffect(() => {
    activateAccountAPI.mutate();
  }, []);

  if (activateAccountAPI.isIdle || activateAccountAPI.isLoading) return <Spinner />;

  return <Navigate to="/" replace />;
}
