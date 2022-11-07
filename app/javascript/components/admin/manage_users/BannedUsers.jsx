import React, { useState } from 'react';
import PropTypes from 'prop-types';
import Pagination from '../../shared_components/Pagination';
import useBannedUsers from '../../../hooks/queries/admin/manage_users/useBannedUsers';
import BannedPendingUsersTable from './BannedPendingUsersTable';

export default function BannedUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: bannedUsers } = useBannedUsers(searchInput, page);

  return (
    <div>
      <BannedPendingUsersTable users={bannedUsers?.data} pendingTable={false} />
      {!isLoading
        && (
          <Pagination
            page={bannedUsers.meta.page}
            totalPages={bannedUsers.meta.pages}
            setPage={setPage}
          />
        )}
    </div>
  );
}

BannedUsers.propTypes = {
  searchInput: PropTypes.string,
};

BannedUsers.defaultProps = {
  searchInput: '',
};
