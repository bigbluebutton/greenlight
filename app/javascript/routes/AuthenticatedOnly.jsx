import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../contexts/auth/AuthProvider';
import VerifyAccount from '../components/users/account_activation/VerifyAccount';

export default function AuthenticatedOnly() {
  const { t } = useTranslation();
  const currentUser = useAuth();

  if (!currentUser.signed_in) {
    toast.error(t('toast.error.signin_required'));
    return <Navigate to="/" />;
  }

  if (!currentUser.verified) {
    return <VerifyAccount currentUser={currentUser} />;
  }

  return <Outlet />;
}
