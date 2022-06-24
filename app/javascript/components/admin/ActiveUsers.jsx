import React from 'react';
import useActiveUsers from '../../hooks/queries/admins/useActiveUsers';
import ManageUsersTable from './ManageUsersTable';

export default function ActiveUsers() {
  const { data: users } = useActiveUsers();

  return (
    <ManageUsersTable users={users} />
  );
}
