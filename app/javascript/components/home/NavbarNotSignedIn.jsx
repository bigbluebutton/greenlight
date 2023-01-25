import React from 'react';
import { Navbar } from 'react-bootstrap';
import AuthButtons from './AuthButtons';

export default function NavbarNotSignedIn() {
  return (
    <>
      <Navbar.Toggle aria-controls="responsive-navbar-nav" className="border-0" />

      {/* Hidden Mobile */}
      <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
        <AuthButtons />
      </Navbar.Collapse>

      {/* Mobile Navbar Toggle */}
      <div className="justify-content-end d-none d-sm-block">
        <AuthButtons />
      </div>
    </>
  );
}
