import React from 'react';
import Container from 'react-bootstrap/Container';
import {
  Nav, NavDropdown, Navbar, Button,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { StarIcon, IdentificationIcon, QuestionMarkCircleIcon } from '@heroicons/react/24/outline';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';
import Avatar from '../users/user/Avatar';
import Logo from './Logo';

export default function Header() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const deleteSession = useDeleteSession();

  const adminAccess = () => {
    const { permissions } = currentUser;
    const {
      ManageUsers, ManageRooms, ManageRecordings, ManageSiteSettings, ManageRoles,
    } = permissions;

    if (ManageUsers === 'true'
      || ManageRooms === 'true'
      || ManageRecordings === 'true'
      || ManageSiteSettings === 'true'
      || ManageRoles === 'true') {
      return true;
    }

    return false;
  };

  let homePath = '/rooms';
  if (currentUser?.permissions?.CreateRoom === 'false') {
    homePath = '/home';
  }

  return (
    <Navbar collapseOnSelect id="navbar" expand="sm">
      <Container className="ps-0">
        <Navbar.Brand as={Link} to={homePath} className="ps-2">
          <Logo />
        </Navbar.Brand>

        <Navbar.Toggle aria-controls="responsive-navbar-nav" className="border-0">
          <Avatar avatar={currentUser?.avatar} radius={40} />
        </Navbar.Toggle>

        {/* /!* Visible only on mobile *!/ */}
        <Navbar.Collapse id="navbar-menu" className="bg-white w-100 position-absolute">
          <Nav className="d-block d-sm-none text-black px-2">
            <Nav.Link eventKey={1} as={Link} to="/profile">
              <IdentificationIcon className="hi-s me-3" />
              {t('user.profile.profile')}
            </Nav.Link>
            <Nav.Link eventKey={2} href="https://docs.bigbluebutton.org/greenlight/gl-overview.html">
              <QuestionMarkCircleIcon className="hi-s me-3" />
              {t('help_center')}
            </Nav.Link>
            {
              adminAccess()
              && (
                <Nav.Link eventKey={3} as={Link} to="/admin">
                  <StarIcon className="hi-s me-3 mb-1" />
                  { t('admin.admin_panel') }
                </Nav.Link>
              )
            }
            <NavDropdown.Divider />
            <Button onClick={deleteSession.mutate} variant="brand" className="btn btn-sm mt-2 mb-3 py-2 w-100">{t('authentication.sign_out')}</Button>
          </Nav>
        </Navbar.Collapse>

        {/* Not visible on mobile */}
        <div className="justify-content-end d-none d-sm-block">
          <div className="d-inline-block">
            <Avatar avatar={currentUser?.avatar} radius={40} />
          </div>
          <NavDropdown title={currentUser?.name} id="nav-user-dropdown" className="d-inline-block" align="end">
            <NavDropdown.Item as={Link} to="/profile">
              <IdentificationIcon className="hi-s me-3" />
              { t('user.profile.profile') }
            </NavDropdown.Item>
            <NavDropdown.Item href="https://docs.bigbluebutton.org/greenlight/gl-overview.html">
              <QuestionMarkCircleIcon className="hi-s me-3" />
              {t('help_center')}
            </NavDropdown.Item>
            {
              adminAccess()
              && (
                <NavDropdown.Item as={Link} to="/admin">
                  <StarIcon className="hi-s me-3 mb-1" />
                  { t('admin.admin_panel') }
                </NavDropdown.Item>
              )
            }
            <NavDropdown.Divider />
            <div className="px-2">
              <Button onClick={deleteSession.mutate} variant="brand" className="btn btn-sm w-100 my-2">{t('authentication.sign_out')}</Button>
            </div>
          </NavDropdown>
        </div>
      </Container>
    </Navbar>
  );
}
