import React from 'react';
import Container from 'react-bootstrap/Container';
import { useLocation, useParams } from 'react-router-dom';

// The background buffer is needed only in /rooms and /rooms/friendly_id
export default function BackgroundBuffer() {
  const location = useLocation();
  const { friendlyId } = useParams();

  // The background buffer is not needed in /rooms/friendly_id/join
  if (location?.pathname.includes(`/rooms/${friendlyId}/join`)) {
    return null;
  }
  if (location?.pathname.includes(`/rooms/${friendlyId}`)) {
    return <Container className="background-lg-buffer" fluid />;
  }
  if (location?.pathname.includes('/rooms')) {
    return <Container className="background-sm-buffer" fluid />;
  }
  return null;
}
