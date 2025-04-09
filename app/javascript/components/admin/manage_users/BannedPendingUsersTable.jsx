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

import React from 'react';
import { Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import BannedPendingRow from './BannedPendingRow';
import EmptyUsersList from './EmptyUsersList';
import ManageUsersPendingBannedRowPlaceHolder from './ManageUsersPendingBannedRowPlaceHolder';
import Pagination from '../../shared_components/Pagination';

export default function BannedPendingUsersTable({
  users, tableType, isLoading, pagination, setPage,
}) {
  const { t } = useTranslation();

  // if (!isLoading && users.length === 0) {
  //   if (pendingTable) {
  //     return <EmptyUsersList text={t('admin.manage_users.empty_pending_users')} subtext={t('admin.manage_users.empty_pending_users_subtext')} />;
  //   }
  //   return <EmptyUsersList text={t('admin.manage_users.empty_banned_users')} subtext={t('admin.manage_users.empty_banned_users_subtext')} />;
  // }
  if (!isLoading && users.length === 0) {
    if (tableType === 'pending') {
      return <EmptyUsersList text={t('admin.manage_users.empty_pending_users')} subtext={t('admin.manage_users.empty_pending_users_subtext')} />;
    }
    if (tableType === 'unverified') {
      return <EmptyUsersList text={t('admin.manage_users.empty_pending_users')} subtext={t('admin.manage_users.empty_unverified_users_subtext')} />;
    }

    return <EmptyUsersList text={t('admin.manage_users.empty_pending_users')} subtext={t('admin.manage_users.empty_banned_users_subtext')} />;
  }

  return (
    <div id="admin-table">
      <Table className="table-bordered border border-2 mb-0" hover responsive>
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">{ t('user.name') } </th>
            <th className="fw-normal border-0">{ t('user.email_address') } </th>
          </tr>
        </thead>
        <tbody className="border-top-0">
          {
            isLoading
              ? (
                // eslint-disable-next-line react/no-array-index-key
                [...Array(5)].map((val, idx) => <ManageUsersPendingBannedRowPlaceHolder key={idx} />)
              )
              : (
                users?.length
                && (
                  users?.map((user) => (
                    <BannedPendingRow key={user.id} user={user} tableType={tableType} />
                  ))
                )
              )
          }
        </tbody>
        { (pagination?.pages > 1)
          && (
            <tfoot>
              <tr>
                <td colSpan={12}>
                  <Pagination
                    page={pagination?.page}
                    totalPages={pagination?.pages}
                    setPage={setPage}
                  />
                </td>
              </tr>
            </tfoot>
          )}
      </Table>
    </div>
  );
}

BannedPendingUsersTable.defaultProps = {
  users: [],
  pagination: {
    page: 1,
    pages: 1,
  },
};

BannedPendingUsersTable.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
  })),
  tableType: PropTypes.string.isRequired,
  isLoading: PropTypes.bool.isRequired,
  pagination: PropTypes.shape({
    page: PropTypes.number.isRequired,
    pages: PropTypes.number.isRequired,
  }),
  setPage: PropTypes.func.isRequired,
};
