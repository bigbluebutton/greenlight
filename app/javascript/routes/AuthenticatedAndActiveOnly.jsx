import React from 'react';
import toast from 'react-hot-toast';
import { Navigate, Outlet } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../contexts/auth/AuthProvider';
import VerifyAccount from '../components/users/account_activation/VerifyAccount';

export default function AuthenticatedAndActiveOnly() {
  const currentUser = useAuth();
  const { t } = useTranslation();

  if (currentUser.signed_out) {
    return <Navigate to="/" />;
  }

  if (!currentUser.signed_in) {
    toast.error(t('toast.error.must_signin_first'));
    return <Navigate to="/signin" />;
  }

  if (!currentUser.active) {
    return <VerifyAccount currentUser={currentUser} />;
  }

  return <Outlet />;
}
