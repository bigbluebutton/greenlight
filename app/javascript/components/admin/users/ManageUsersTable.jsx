import React from 'react';
import { Table } from 'react-bootstrap';
import PropTypes from 'prop-types';
import AdminUserRow from './AdminUserRow';

export default function ManageUsersTable({ users }) {
  return (
    <Table hover className="text-secondary mb-0 recordings-list">
      <thead>
        <tr className="text-muted small">
          <th className="fw-normal">Name</th>
          <th className="fw-normal">User Name</th>
          <th className="fw-normal">Authenticator</th>
          <th className="fw-normal">Role</th>
          <th aria-label="options" />
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
