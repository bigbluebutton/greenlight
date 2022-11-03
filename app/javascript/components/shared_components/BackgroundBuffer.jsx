import React from 'react';
import Container from 'react-bootstrap/Container';
import { useLocation, useParams } from 'react-router-dom';

export default function BackgroundBuffer() {
  const location = useLocation();

  if (location?.pathname.startsWith('/rooms')) {
    const { friendlyId } = useParams();

    if (location?.pathname === `/rooms/${friendlyId}`) {
      return <Container className="background-lg-buffer" fluid />;
    }
    return <Container className="background-sm-buffer" fluid />;
  }

  return null;
}
