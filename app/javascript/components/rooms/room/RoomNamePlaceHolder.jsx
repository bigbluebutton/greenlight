import React from 'react';
import Stack from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function RoomNamePlaceHolder() {
  return (
    <Stack className="room-header-wrapper">
      <Placeholder width={8} size="lg" className="me-2" />
      <Placeholder width={6} size="lg" className="me-2" />
    </Stack>
  );
}
