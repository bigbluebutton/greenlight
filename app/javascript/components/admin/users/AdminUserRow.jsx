import React from 'react';
import PropTypes from 'prop-types';
import { Stack } from 'react-bootstrap';
import { DotsVerticalIcon } from '@heroicons/react/outline';
import Avatar from '../../users/Avatar';

export default function AdminUserRow({ user, setEdit }) {
  return (
    <tr key={user.id} className="align-middle text-muted">
      <td className="text-dark border-end-0">
        <Stack direction="horizontal">
          <div className="me-2">
            <Avatar avatar={user.avatar} radius={40} />
          </div>
          <Stack>
            <strong> {user.name} </strong>
            <span className="small text-muted"> Created: {user.created_at} </span>
          </Stack>
        </Stack>
      </td>

      <td className="border-0"> {user.email} </td>
      <td className="border-0"> {user.provider} </td>
      <td className="border-0"> {user.role}</td>
      <td className="border-start-0">
        <DotsVerticalIcon onClick={() => setEdit(true)} className="cursor-pointer hi-s text-muted" />
      </td>
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
  setEdit: PropTypes.func.isRequired,
};
