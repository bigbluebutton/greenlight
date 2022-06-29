import React from 'react';
import useActiveUsers from '../../../hooks/queries/admins/useActiveUsers';
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import useActiveUsers from '../../hooks/queries/admins/useActiveUsers';
import ManageUsersTable from './ManageUsersTable';
import Spinner from '../../shared/stylings/Spinner';

export default function ActiveUsers({ input }) {
  const [activeUsers, setActiveUsers] = useState();
  const { isLoading } = useActiveUsers(input, setActiveUsers);

  if (isLoading) return <Spinner />;

  return (
    <ManageUsersTable users={activeUsers} />
  );
}

ActiveUsers.propTypes = {
  input: PropTypes.string,
};

ActiveUsers.defaultProps = {
  input: '',
};
