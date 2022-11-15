import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'react-bootstrap';
import useBannedUsers from '../../../hooks/queries/admin/manage_users/useBannedUsers';
import BannedPendingUsersTable from './BannedPendingUsersTable';

export default function BannedUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: bannedUsers } = useBannedUsers(searchInput, page);

  if (isLoading) return <Spinner />;

  return (
    <BannedPendingUsersTable users={bannedUsers?.data} pendingTable={false} setPage={setPage} />
  );
}

BannedUsers.propTypes = {
  searchInput: PropTypes.string,
};

BannedUsers.defaultProps = {
  searchInput: '',
};
