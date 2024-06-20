// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
