import React from 'react';
import { Container } from 'react-bootstrap';
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
