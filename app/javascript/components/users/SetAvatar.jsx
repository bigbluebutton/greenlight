import React from 'react';
import { Stack } from 'react-bootstrap';
import AvatarForm from '../forms/AvatarForm';
import Avatar from './Avatar';

export default function SetAvatar() {
  return (
    <Stack direction="horizontal" gap={3} className="mb-3">
      <Avatar radius={150} />
      <AvatarForm />
    </Stack>
  );
}
