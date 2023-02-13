import React from 'react';
import { Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import BannedPendingRow from './BannedPendingRow';
import EmptyUsersList from './EmptyUsersList';
import ManageUsersPendingBannedRowPlaceHolder from './ManageUsersPendingBannedRowPlaceHolder';
import Pagination from '../../shared_components/Pagination';

// pendingTable prop is true when table is being used for pending data, false when table is being used for banned data
export default function BannedPendingUsersTable({ users, pendingTable, isLoading, pagination, setPage }) {
  const { t } = useTranslation();

  if (!isLoading && users.length === 0) {
    if (pendingTable) {
      return <EmptyUsersList text={t('admin.manage_users.empty_pending_users')} subtext={t('admin.manage_users.empty_pending_users_subtext')} />;
    }
    return <EmptyUsersList text={t('admin.manage_users.empty_banned_users')} subtext={t('admin.manage_users.empty_banned_users_subtext')} />;
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
                    <BannedPendingRow key={user.id} user={user} pendingTable={pendingTable} />
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
  pagination: {},
};

BannedPendingUsersTable.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
  })),
  pendingTable: PropTypes.bool.isRequired,
  isLoading: PropTypes.bool.isRequired,
  pagination: PropTypes.shape({
    page: PropTypes.number.isRequired,
    pages: PropTypes.number.isRequired,
  }),
  setPage: PropTypes.func.isRequired,
};
