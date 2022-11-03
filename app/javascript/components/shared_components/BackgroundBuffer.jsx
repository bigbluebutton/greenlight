import React from 'react';
import Container from 'react-bootstrap/Container';
import { useLocation } from 'react-router-dom';

export default function BackgroundBuffer() {
  const location = useLocation();

  if (location?.pathname.startsWith('/rooms/')) {
    return <Container className="background-lg-buffer" fluid />;
  }

  if (location?.pathname.startsWith('/rooms')) {
    return <Container className="background-sm-buffer" fluid />;
  }

  return null;
}
