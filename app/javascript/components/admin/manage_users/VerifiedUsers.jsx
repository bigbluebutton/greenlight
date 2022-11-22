import React, { useState } from 'react';
import PropTypes from 'prop-types';
import useVerifiedUsers from '../../../hooks/queries/admin/manage_users/useVerifiedUsers';
import ManageUsersTable from './ManageUsersTable';
import Pagination from '../../shared_components/Pagination';

export default function VerifiedUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: verifiedUsers } = useVerifiedUsers(searchInput, page);

  return (
    <div>
      <ManageUsersTable users={verifiedUsers?.data} isLoading={isLoading} />
      {!isLoading
        && (
          <Pagination
            page={verifiedUsers.meta.page}
            totalPages={verifiedUsers.meta.pages}
            setPage={setPage}
          />
        )}
    </div>
  );
}

VerifiedUsers.propTypes = {
  searchInput: PropTypes.string,
};

VerifiedUsers.defaultProps = {
  searchInput: '',
};
