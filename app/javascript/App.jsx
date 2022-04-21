import React from 'react';
import { Container } from 'react-bootstrap';
import { Outlet } from 'react-router-dom';
import Header from './components/shared/Header';
import { useAuth } from './contexts/auth/AuthProvider';

export default function App() {
  const currentUser = useAuth();

  return (
    <>
      {currentUser?.signed_in && <Header /> }
      <Container>
        <Outlet />
      </Container>
    </>
  );
}
