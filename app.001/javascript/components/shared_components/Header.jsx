import React from 'react';
import Container from 'react-bootstrap/Container';
import {
  Navbar,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import Logo from './Logo';
import NavbarSignedIn from '../home/NavbarSignedIn';
import NavbarNotSignedIn from '../home/NavbarNotSignedIn';
import RTLSwitcher from '../arabic/RTLSwitcher';
// import { useTranslation } from 'react-i18next';

export default function Header() {
  const currentUser = useAuth();

  let homePath = '/';
  if (currentUser?.permissions?.CreateRoom === 'false') {
    homePath = '/home';
  }

  return (
    <Navbar collapseOnSelect id="navbar" expand="sm">
      <Container className="ps-0">
        <Navbar.Brand as={Link} to={homePath} className="ps-2">
          <Logo size="small" />
        </Navbar.Brand>
        <RTLSwitcher />
        {
          currentUser.signed_in
            ? (
              <NavbarSignedIn currentUser={currentUser} />
            ) : (
              <NavbarNotSignedIn />
            )
        }

      </Container>
    </Navbar>
  );
}
