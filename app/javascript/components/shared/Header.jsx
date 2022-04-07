import React from 'react';
import Container from 'react-bootstrap/Container';
import { Navbar, NavDropdown, Stack } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useAuth } from '../sessions/AuthProvider';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';
import ButtonLink from '../stylings/buttons/ButtonLink';

export default function Header() {
  const currentUser = useAuth();
  const { handleSignOut } = useDeleteSession();

  return (
    <Navbar bg="light">
      <Container>
        <Navbar.Brand as={Link} to="/">
          <img
            src="https://blindsidenetworks.com/wp-content/uploads/2021/04/cropped-bn_logo-02.png"
            width="200"
            height=""
            className="d-inline-block align-top"
            alt="CompanyLogo"
          />
        </Navbar.Brand>

        {currentUser?.signed_in
          ? (
            <NavDropdown title={currentUser?.name} id="basic-nav-dropdown">
              <NavDropdown.Item as={Link} to="/">Profile</NavDropdown.Item>
              <NavDropdown.Item as={Link} to="/">Need help?</NavDropdown.Item>
              <NavDropdown.Divider />
              <NavDropdown.Item as={Link} to="/" onClick={handleSignOut}>Sign Out</NavDropdown.Item>
            </NavDropdown>
          )

          : (
            <Stack direction="horizontal">
              <ButtonLink to="/signin" className="mx-2">Sign In</ButtonLink>
              <ButtonLink to="/signup" variant="outline-primary">Sign Up</ButtonLink>
            </Stack>
          )}

      </Container>
    </Navbar>

  );
}
