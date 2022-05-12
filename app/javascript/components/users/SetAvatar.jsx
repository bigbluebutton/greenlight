import React from 'react';
import { Stack } from 'react-bootstrap';
import AvatarForm from '../forms/AvatarForm';
import DeleteAvatarForm from '../forms/DeleteAvatarForm';
import Avatar from './Avatar';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function SetAvatar() {
  const currentUser = useAuth();

  return (
    <Stack direction="horizontal" gap={3} className="mb-3">
      <Avatar avatar={currentUser?.avatar} radius={150} />
      <Stack direction="vertical">
        <AvatarForm />
        <DeleteAvatarForm />
      </Stack>
    </Stack>
  );
}
