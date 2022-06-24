import React from 'react';
import PropTypes from 'prop-types';
import { Stack } from 'react-bootstrap';
import Avatar from '../users/Avatar';

export default function AdminUserRow({ user }) {
  return (
    <tr key={user.id} className="align-middle text-muted">
      <td className="text-dark">
        <Stack direction="horizontal">
          <div>
            <Avatar className="avatar" avatar={user.avatar} radius={40} />
          </div>
          <Stack>
            <strong> {user.name} </strong>
            <span className="small text-muted"> Created: {user.created_at} </span>
          </Stack>
        </Stack>
      </td>

      <td> {user.email} </td>
      <td> {user.provider} </td>
      <td> {user.role}</td>
    </tr>
  );
}

AdminUserRow.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
};
