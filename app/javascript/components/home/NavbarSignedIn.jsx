import React from 'react';
import {
  Button, Nav, Navbar, NavDropdown,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { IdentificationIcon, QuestionMarkCircleIcon, StarIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import useDeleteSession from '../../hooks/mutations/sessions/useDeleteSession';
import Avatar from '../users/user/Avatar';

export default function NavbarSignedIn({ currentUser }) {
  const { t } = useTranslation();
  const deleteSession = useDeleteSession();

  const adminAccess = () => {
    const { permissions } = currentUser;
    const {
      ManageUsers, ManageRooms, ManageRecordings, ManageSiteSettings, ManageRoles,
    } = permissions;

    // Todo: Use PermissionChecker.
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
    <>
      <Navbar.Toggle aria-controls="responsive-navbar-nav" className="border-0">
        <Avatar avatar={currentUser?.avatar} size="small" />
      </Navbar.Toggle>

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
          <Button
            onClick={deleteSession.mutate}
            variant="brand"
            className="btn btn-sm mt-2 mb-3 py-2 w-100"
          >{t('authentication.sign_out')}
          </Button>
        </Nav>
      </Navbar.Collapse>

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
    </>
  );
}
