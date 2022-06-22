import React from 'react';
import { Container } from 'react-bootstrap';
import { Outlet } from 'react-router-dom';
import Header from './components/shared/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import {Toaster} from "react-hot-toast";

export default function App() {
  const currentUser = useAuth();
  const containerHeight = currentUser?.signed_in ? 'full-height' : 'h-100';
  return (
    <>
      {currentUser?.signed_in && <Header /> }
      <Container className={containerHeight}>
        <Outlet />
      </Container>
      <Toaster
        position="bottom-right"
      />
    </>
  );
}
