import React from 'react';
import Container from 'react-bootstrap/Container';
import { useLocation, useParams } from 'react-router-dom';

export default function BackgroundBuffer() {
  const location = useLocation();
  const { friendlyId } = useParams();

  // The buffer is not needed if pathname doesn't start with /rooms
  if (!location?.pathname.startsWith('/rooms')) {
    return null;
  }

  if (location?.pathname === `/rooms/${friendlyId}`) {
    return <Container className="background-lg-buffer" fluid />;
  }
  return <Container className="background-sm-buffer" fluid />;
}
