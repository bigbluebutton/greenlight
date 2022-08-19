import React from 'react';
import Container from 'react-bootstrap/Container';
import { Navbar, NavDropdown } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';
import Avatar from '../users/user/Avatar';
import Logo from './Logo';

export default function Header() {
  const currentUser = useAuth();
  const deleteSession = useDeleteSession();

  return (
    <Navbar>
      <Container>
        <Navbar.Brand as={Link} to="/rooms">
          <Logo />
        </Navbar.Brand>

        <div className="d-inline-flex">
          <Avatar avatar={currentUser?.avatar} radius={40} />
          <NavDropdown title={currentUser?.name} id="nav-user-dropdown">
            <NavDropdown.Item as={Link} to="/profile">Profile</NavDropdown.Item>
            {/* TODO: Only show admin panel when current user is admin */}
            <NavDropdown.Item as={Link} to="/adminpanel">Admin Panel</NavDropdown.Item>
            <NavDropdown.Item as={Link} to="/">Need help?</NavDropdown.Item>
            <NavDropdown.Divider />
            <NavDropdown.Item as={Link} to="/" onClick={deleteSession.mutate}>Sign Out</NavDropdown.Item>
          </NavDropdown>
        </div>
      </Container>
    </Navbar>
  );
}
