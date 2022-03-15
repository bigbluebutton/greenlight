import React from 'react';
import { Col, Container, Row } from 'react-bootstrap';
import { Outlet } from 'react-router-dom';
import CurrentUser from './components/user/CurrentUser';

export default function () {
  return (
    <Container>
      <CurrentUser />
      <Outlet />
    </Container>
  );
}
