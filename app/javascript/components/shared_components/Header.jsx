import React from 'react';
import Container from 'react-bootstrap/Container';
import { Navbar, NavDropdown } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
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

  return (
    <Navbar className="header">
      <Container className="ps-0">
        <Navbar.Brand as={Link} to="/rooms">
          <Logo />
        </Navbar.Brand>

        <div className="d-inline-flex">
          <Avatar avatar={currentUser?.avatar} radius={40} />
          <NavDropdown title={currentUser?.name} id="nav-user-dropdown">
            <NavDropdown.Item as={Link} to="/profile">{ t('user.profile.profile') }</NavDropdown.Item>
            {
              adminAccess()
              && <NavDropdown.Item as={Link} to="/admin">{ t('admin.admin_panel') }</NavDropdown.Item>
            }
            <NavDropdown.Item as={Link} to="/">{ t('need_help') }</NavDropdown.Item>
            <NavDropdown.Divider />
            <NavDropdown.Item onClick={deleteSession.mutate}>{ t('authentication.sign_out') }</NavDropdown.Item>
          </NavDropdown>
        </div>
      </Container>
    </Navbar>
  );
}
