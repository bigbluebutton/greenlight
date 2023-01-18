import React from 'react';
import { Nav, Navbar } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { IdentificationIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import AuthButtons from './AuthButtons';

export default function NavbarNotSignedIn() {
  const { t } = useTranslation();

  return (
    <>
      <Navbar.Toggle aria-controls="responsive-navbar-nav" className="border-0" />

      <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
        <Nav className="d-block d-sm-none text-black px-2">
          <Nav.Link eventKey={1} as={Link} to="/signin">
            <IdentificationIcon className="hi-s me-3" />
            {t('signin')}
          </Nav.Link>
          <Nav.Link eventKey={2} as={Link} to="/signup">
            <IdentificationIcon className="hi-s me-3" />
            {t('signup')}
          </Nav.Link>
        </Nav>
      </Navbar.Collapse>

      <div className="justify-content-end d-none d-sm-block">
        <AuthButtons />
      </div>
    </>
  );
}
