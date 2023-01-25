import React from 'react';
import {Nav, Navbar} from 'react-bootstrap';
import AuthButtons from './AuthButtons';

export default function NavbarNotSignedIn() {
  return (
    <>
      <Navbar.Toggle aria-controls="responsive-navbar-nav" className="border-0" />

      {/* Hidden Mobile */}
      <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
        <Nav className="d-block d-sm-none text-black px-2">
          <AuthButtons direction="vertical" />
        </Nav>
      </Navbar.Collapse>

      {/* Mobile Navbar Toggle */}
      <div className="justify-content-end d-none d-sm-block">
        <AuthButtons />
      </div>
    </>
  );
}