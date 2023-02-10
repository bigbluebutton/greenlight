import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Pagination from '../../shared_components/Pagination';
import usePendingUsers from '../../../hooks/queries/admin/manage_users/usePendingUsers';
import BannedPendingUsersTable from './BannedPendingUsersTable';
import NoSearchResults from '../../shared_components/search/NoSearchResults';

export default function PendingUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: users } = usePendingUsers(searchInput, page);
  const { t } = useTranslation();

  return (
    <div>
      {
      (searchInput && users?.data.length === 0)
        ? (
          <div className="mt-5">
            <NoSearchResults text={t('user.search_not_found')} searchInput={searchInput} />
          </div>
        ) : (
          <div>
            <BannedPendingUsersTable users={users?.data} pendingTable isLoading={isLoading} />
            {!isLoading
        && (
        <Pagination
          page={users?.meta.page}
          totalPages={users?.meta.pages}
          setPage={setPage}
        />
        )}
          </div>
        )
        }
    </div>
  );
}

PendingUsers.propTypes = {
  searchInput: PropTypes.string,
};

PendingUsers.defaultProps = {
  searchInput: '',
};
