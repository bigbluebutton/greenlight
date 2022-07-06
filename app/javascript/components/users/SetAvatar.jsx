import React from 'react';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import AvatarForm from '../forms/AvatarForm';
import DeleteAvatarForm from '../forms/DeleteAvatarForm';
import Avatar from './Avatar';

export default function SetAvatar({ user }) {
  return (
    <Stack direction="horizontal" gap={3} className="mb-3">
      <Avatar avatar={user?.avatar} radius={150} />
      <Stack direction="vertical">
        <AvatarForm user={user} />
        <DeleteAvatarForm user={user} />
      </Stack>
    </Stack>
  );
}

SetAvatar.propTypes = {
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
