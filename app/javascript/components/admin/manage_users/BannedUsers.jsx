import React, { useState } from 'react';
import PropTypes from 'prop-types';
import ManageUsersTable from './ManageUsersTable';
import Pagination from '../../shared_components/Pagination';
import useBannedUsers from '../../../hooks/queries/admin/manage_users/useBannedUsers';

export default function BannedUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: bannedUsers } = useBannedUsers(searchInput, page);

  return (
    <div>
      <ManageUsersTable users={bannedUsers?.data} />
      {!isLoading
        && (
          <div className="pagination-wrapper">
            <Pagination
              page={bannedUsers.meta.page}
              totalPages={bannedUsers.meta.pages}
              setPage={setPage}
            />
          </div>
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
