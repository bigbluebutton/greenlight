import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Pagination from '../../shared_components/Pagination';
import useBannedUsers from '../../../hooks/queries/admin/manage_users/useBannedUsers';
import BannedPendingUsersTable from './BannedPendingUsersTable';
import NoSearchResults from '../../shared_components/search/NoSearchResults';

export default function BannedUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: bannedUsers } = useBannedUsers(searchInput, page);
  const { t } = useTranslation();

  return (
    <div>
      {
      (searchInput && bannedUsers?.data.length === 0)
        ? (
          <div className="mt-5">
            <NoSearchResults text={t('user.search_not_found')} searchInput={searchInput} />
          </div>
        ) : (
          <BannedPendingUsersTable users={bannedUsers?.data} pendingTable={false} isLoading={isLoading} pagination={bannedUsers?.meta} setPage={setPage} />
        )
      }
    </div>
  );
}

BannedUsers.propTypes = {
  searchInput: PropTypes.string,
};

BannedUsers.defaultProps = {
  searchInput: '',
};
