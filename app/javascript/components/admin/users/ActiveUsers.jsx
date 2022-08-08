import React, { useState } from 'react';
import PropTypes from 'prop-types';
import useActiveUsers from '../../../hooks/queries/admin/manage_users/useActiveUsers';
import ManageUsersTable from './ManageUsersTable';
import Pagy from '../../shared/Pagy';

export default function ActiveUsers({ input }) {
  const [page, setPage] = useState();
  const { isLoading, data: activeUsers } = useActiveUsers(input, page);

  return (
    <div>
      <ManageUsersTable users={activeUsers?.data} />
      {!isLoading
        && (
        <Pagy
          page={activeUsers.meta.page}
          totalPages={activeUsers.meta.pages}
          setPage={setPage}
        />
        )}
    </div>
  );
}

ActiveUsers.propTypes = {
  input: PropTypes.string,
};

ActiveUsers.defaultProps = {
  input: '',
};
