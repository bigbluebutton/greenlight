import React from 'react';
import useActiveUsers from '../../../hooks/queries/admins/useActiveUsers';
import ManageUsersTable from './ManageUsersTable';
import Spinner from '../../shared/stylings/Spinner';

export default function ActiveUsers() {
  const { isLoading, data: users } = useActiveUsers();

  if (isLoading) return <Spinner />;

  return (
    <ManageUsersTable users={users} />
  );
}
