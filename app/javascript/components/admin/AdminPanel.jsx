import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function AdminPanel() {
  const currentUser = useAuth();

  const navigateTo = () => {
    const { permissions } = currentUser;
    const {
      ManageUsers, ManageRooms, ManageRecordings, ManageSiteSettings, ManageRoles,
    } = permissions;

    if (ManageUsers === 'true') {
      return '/admin/users';
    }

    if (ManageRooms === 'true') {
      return '/admin/server_rooms';
    }

    if (ManageRecordings === 'true') {
      return '/admin/server_recordings';
    }

    if (ManageSiteSettings === 'true') {
      return '/admin/site_settings';
    }

    if (ManageRoles === 'true') {
      return '/admin/roles';
    }

    return '/';
  };

  return (
    <Navigate to={navigateTo()} replace />
  );
}
