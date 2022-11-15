import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'react-bootstrap';
import useVerifiedUsers from '../../../hooks/queries/admin/manage_users/useVerifiedUsers';
import ManageUsersTable from './ManageUsersTable';

export default function VerifiedUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: verifiedUsers } = useVerifiedUsers(searchInput, page);

  if (isLoading) return <Spinner />;

  return (
    <ManageUsersTable users={verifiedUsers} setPage={setPage} />
  );
}

VerifiedUsers.propTypes = {
  searchInput: PropTypes.string,
};

VerifiedUsers.defaultProps = {
  searchInput: '',
};
