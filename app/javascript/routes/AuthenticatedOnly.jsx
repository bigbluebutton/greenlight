import React from 'react';
import {
  Navigate, Outlet, useLocation, useMatch,
} from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../contexts/auth/AuthProvider';
import useDeleteSession from '../hooks/mutations/sessions/useDeleteSession';

export default function AuthenticatedOnly() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const location = useLocation();
  const match = useMatch('/rooms/:friendlyId');
  const deleteSession = useDeleteSession({ showToast: false });

  // User is either pending or banned
  if (currentUser.signed_in && currentUser.status !== 'active') {
    deleteSession.mutate();

    if (currentUser.status === 'pending') {
      toast.error(t('toast.error.users.pending'));
    } else {
      toast.error(t('toast.error.users.banned'));
    }
  }

  // Custom logic to redirect from Rooms page to join page if the user isn't signed in
  if (!currentUser.signed_in && match) {
    return <Navigate to={`${location.pathname}/join`} />;
  }

  if (!currentUser.signed_in) {
    toast.error(t('toast.error.signin_required'));
    return <Navigate to="/" />;
  }

  return <Outlet />;
}
