// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import { Nav, Navbar } from 'react-bootstrap';
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
