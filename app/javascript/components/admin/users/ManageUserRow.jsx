import React from 'react';
import PropTypes from 'prop-types';
import {
  Stack, Navbar, NavDropdown, Container,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { DotsVerticalIcon } from '@heroicons/react/outline';
import Avatar from '../../users/Avatar';

export default function ManageUserRow({ user }) {
  return (
    <tr key={user.id} className="align-middle text-muted">
      <td className="text-dark border-end-0">
        <Stack direction="horizontal">
          <div className="me-2">
            <Avatar avatar={user.avatar} radius={40} />
          </div>
          <Stack>
            <strong> {user.name} </strong>
            <span className="small text-muted"> Created: {user.created_at} </span>
          </Stack>
        </Stack>
      </td>

      <td className="border-0"> {user.email} </td>
      <td className="border-0"> {user.provider} </td>
      <td className="border-0"> {user.role}</td>
      <td className="border-start-0">
        <Navbar>
          <Container>
            <div className="d-inline-flex">
              <NavDropdown title={<DotsVerticalIcon className="hi-s text-muted" />} id="basic-nav-dropdown">
                <NavDropdown.Item as={Link} to={`/adminpanel/edit_user/${user.id}`}>Edit</NavDropdown.Item>
                <NavDropdown.Item as={Link} to={`/adminpanel/delete_user/${user.id}`}>Delete</NavDropdown.Item>
              </NavDropdown>
            </div>
          </Container>
        </Navbar>
      </td>
    </tr>
  );
}

ManageUserRow.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
};
