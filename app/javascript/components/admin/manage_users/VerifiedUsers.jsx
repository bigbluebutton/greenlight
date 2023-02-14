import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import useVerifiedUsers from '../../../hooks/queries/admin/manage_users/useVerifiedUsers';
import ManageUsersTable from './ManageUsersTable';
import NoSearchResults from '../../shared_components/search/NoSearchResults';

export default function VerifiedUsers({ searchInput }) {
  const [page, setPage] = useState();
  const { isLoading, data: verifiedUsers } = useVerifiedUsers(searchInput, page);
  const { t } = useTranslation();

  return (
    <div>
      {
      (searchInput && verifiedUsers?.data.length === 0)
        ? (
          <div className="mt-5">
            <NoSearchResults text={t('user.search_not_found')} searchInput={searchInput} />
          </div>
        ) : (
          <ManageUsersTable users={verifiedUsers?.data} isLoading={isLoading} pagination={verifiedUsers?.meta} setPage={setPage} />
        )
    }
    </div>
  );
}

VerifiedUsers.propTypes = {
  searchInput: PropTypes.string,
};

VerifiedUsers.defaultProps = {
  searchInput: '',
};
