import React, { useState } from 'react';
import PropTypes from 'prop-types';
import useActiveUsers from '../../../hooks/queries/admin/manage_users/useActiveUsers';
import ManageUsersTable from './ManageUsersTable';
import Pagination from '../../shared_components/Pagination';

export default function ActiveUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: activeUsers } = useActiveUsers(searchInput, page);

  return (
    <div>
      <ManageUsersTable users={activeUsers?.data} />
      {!isLoading
        && (
          <div className="pagination-wrapper">
            <Pagination
              page={activeUsers.meta.page}
              totalPages={activeUsers.meta.pages}
              setPage={setPage}
            />
          </div>
        )}
    </div>
  );
}

ActiveUsers.propTypes = {
  searchInput: PropTypes.string,
};

ActiveUsers.defaultProps = {
  searchInput: '',
};
