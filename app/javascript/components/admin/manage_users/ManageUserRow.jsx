import React from 'react';
import PropTypes from 'prop-types';
import {
  Stack, Navbar, NavDropdown, Container,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import {
  EllipsisVerticalIcon, HomeIcon, PencilSquareIcon, TrashIcon,
} from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import Avatar from '../../users/user/Avatar';
import Modal from '../../shared_components/modals/Modal';
import CreateRoomForm from '../../rooms/room/forms/CreateRoomForm';
import useCreateServerRoom from '../../../hooks/mutations/admin/manage_users/useCreateServerRoom';
import DeleteUserForm from './forms/DeleteUserForm';
import RolePill from '../roles/RolePill';

export default function ManageUserRow({ user }) {
  const { t } = useTranslation();
  const mutationWrapper = (args) => useCreateServerRoom({ userId: user.id, ...args });

  return (
    <tr key={user.id} className="align-middle text-muted">
      <td className="text-dark border-end-0">
        <Stack direction="horizontal">
          <div className="me-2">
            <Avatar avatar={user.avatar} radius={40} />
          </div>
          <Stack>
            <strong> {user.name} </strong>
            <span className="small text-muted"> { t('admin.manage_users.user_created_at', { user }) }</span>
          </Stack>
        </Stack>
      </td>

      <td className="border-0"> {user.email} </td>
      <td className="border-0"> <RolePill role={user.role} /> </td>
      <td className="border-start-0">
        <Navbar>
          <Container>
            <div className="d-inline-flex">
              <NavDropdown title={<EllipsisVerticalIcon className="hi-s text-muted" />} id="basic-nav-dropdown">
                <NavDropdown.Item as={Link} to={`/admin/edit_user/${user.id}`}><PencilSquareIcon className="hi-s" />{ t('edit') }</NavDropdown.Item>
                <Modal
                  modalButton={<NavDropdown.Item><TrashIcon className="hi-s" />{ t('delete') }</NavDropdown.Item>}
                  title={t('admin.manage_users.delete_user')}
                  body={<DeleteUserForm user={user} />}
                />
                <Modal
                  modalButton={<NavDropdown.Item><HomeIcon className="hi-s" />{ t('admin.manage_users.create_room') }</NavDropdown.Item>}
                  title={t('admin.manage_users.create_new_room')}
                  body={<CreateRoomForm mutation={mutationWrapper} userId={user.id} />}
                />
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
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
};
