import React from 'react';
import { Table } from 'react-bootstrap';
import PropTypes from 'prop-types';
import AdminUserRow from './AdminUserRow';

export default function ManageUsersTable({ users }) {
  return (
    <div id="admin-table">
      <Table className="table-bordered border border-2" hover>
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">Name</th>
            <th className="fw-normal border-0">User Name</th>
            <th className="fw-normal border-0">Authenticator</th>
            <th className="fw-normal border-0">Role</th>
            <th className="border-start-0" aria-label="options" />
          </tr>
        </thead>
        <tbody className="border-top-0">
          {users?.length
            ? (
              users?.map((user) => <AdminUserRow key={user.id} user={user} />)
            )
            : (
              <tr>
                <td className="fw-bold">
                  No users found!
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
    id: PropTypes.number.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.string.isRequired,
  })),
};
