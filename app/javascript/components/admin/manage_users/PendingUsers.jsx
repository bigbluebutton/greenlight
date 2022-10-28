import React, { useState } from 'react';
import PropTypes from 'prop-types';
import Pagination from '../../shared_components/Pagination';
import usePendingUsers from '../../../hooks/queries/admin/manage_users/usePendingUsers';
import BannedPendingUsersTable from './BannedPendingUsersTable';

export default function PendingUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: users } = usePendingUsers(searchInput, page);

  return (
    <div>
      <BannedPendingUsersTable users={users?.data} pendingTable />
      {!isLoading
        && (
        <div className="pagination-wrapper">
          <Pagination
            page={users?.meta.page}
            totalPages={users?.meta.pages}
            setPage={setPage}
          />
        </div>
        )}
    </div>
  );
}

PendingUsers.propTypes = {
  searchInput: PropTypes.string,
};

PendingUsers.defaultProps = {
  searchInput: '',
};
