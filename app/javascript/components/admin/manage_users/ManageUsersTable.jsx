import React from 'react';
import { Table } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import ManageUserRow from './ManageUserRow';

export default function ManageUsersTable({ users }) {
  const { t } = useTranslation();

  return (
    <div id="admin-table">
      <Table className="table-bordered border border-2 mb-0" hover>
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">{ t('user.name') }</th>
            <th className="fw-normal border-0">{ t('user.email_address') }</th>
            <th className="fw-normal border-0">{ t('user.authenticator') }</th>
            <th className="fw-normal border-0">{ t('user.profile.role') }</th>
            <th className="border-start-0" aria-label="options" />
          </tr>
        </thead>
        <tbody className="border-top-0">
          {users?.length
            ? (
              users?.map((user) => <ManageUserRow key={user.id} user={user} />)
            )
            : (
              <tr>
                <td className="fw-bold">
                  { t('user.no_user_found') }
                </td>
              </tr>
            )}
        </tbody>
      </Table>
    </div>
  );
}

ManageUsersTable.defaultProps = {
  users: [],
};

ManageUsersTable.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
  })),
};
