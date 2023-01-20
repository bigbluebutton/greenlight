import React from 'react';
import { Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import BannedPendingRow from './BannedPendingRow';

// pendingTable prop is true when table is being used for pending data, false when table is being used for banned data
export default function BannedPendingUsersTable({ users, pendingTable }) {
  const { t } = useTranslation();

  return (
    <div id="admin-table">
      <Table className="table-bordered border border-2 mb-0" hover responsive>
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">{ t('user.name') } </th>
            <th className="fw-normal border-0">{ t('user.email_address') } </th>
            <th className="fw-normal border-0">{ t('created_at') } </th>
          </tr>
        </thead>
        <tbody className="border-top-0">
          {users?.length
            ? (
              users?.map((user) => (
                <BannedPendingRow key={user.id} user={user} pendingTable={pendingTable} />
              ))
            )
            : (
              <tr>
                <td className="fw-bold" colSpan="6">
                  { t('user.no_user_found') }
                </td>
              </tr>
            )}
        </tbody>
      </Table>
    </div>
  );
}

BannedPendingUsersTable.defaultProps = {
  users: [],
};

BannedPendingUsersTable.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
  })),
  pendingTable: PropTypes.bool.isRequired,
};
