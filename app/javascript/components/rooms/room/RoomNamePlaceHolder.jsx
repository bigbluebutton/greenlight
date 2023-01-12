import React from 'react';
import { Stack } from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function RoomNamePlaceHolder() {
  return (
    <Stack className="room-header-wrapper">
      <Placeholder width={8} size="xlg" className="mb-3" />
      <Placeholder width={6} size="lg" className="mb-3" />
    </Stack>
  );
}
