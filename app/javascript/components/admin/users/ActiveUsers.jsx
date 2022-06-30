import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Container } from 'react-bootstrap';
import useActiveUsers from '../../../hooks/queries/admins/useActiveUsers';
import ManageUsersTable from './ManageUsersTable';
import Spinner from '../../shared/stylings/Spinner';
import EditUser from './EditUser';

export default function ActiveUsers({ input }) {
  const [activeUsers, setActiveUsers] = useState();
  const [edit, setEdit] = useState();
  const { isLoading } = useActiveUsers(input, setActiveUsers);

  if (isLoading) return <Spinner />;

  return (
    <Container>
      {edit ? (
        <EditUser setEdit={setEdit} />
      ) : (
        <ManageUsersTable users={activeUsers} setEdit={setEdit} />
      )}
    </Container>

  );
}

ActiveUsers.propTypes = {
  input: PropTypes.string,
};

ActiveUsers.defaultProps = {
  input: '',
};
