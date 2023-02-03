import React from 'react';
import PropTypes from 'prop-types';
import {
  Stack,
  Dropdown,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import {
  EllipsisVerticalIcon, HomeIcon, PencilSquareIcon, TrashIcon, NoSymbolIcon,
} from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import Avatar from '../../users/user/Avatar';
import Modal from '../../shared_components/modals/Modal';
import CreateRoomForm from '../../rooms/room/forms/CreateRoomForm';
import useCreateServerRoom from '../../../hooks/mutations/admin/manage_users/useCreateServerRoom';
import DeleteUserForm from './forms/DeleteUserForm';
import useUpdateUserStatus from '../../../hooks/mutations/admin/manage_users/useUpdateUserStatus';
import RoleBadge from '../roles/RoleBadge';

export default function ManageUserRow({ user }) {
  const { t } = useTranslation();
  const mutationWrapper = (args) => useCreateServerRoom({ userId: user.id, ...args });
  const updateUserStatus = useUpdateUserStatus();

  return (
    <tr key={user.id} className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack direction="horizontal">
          <div className="me-2">
            <Avatar avatar={user.avatar} size="small" />
          </div>
          <Stack>
            <span className="text-dark fw-bold"> {user.name} </span>
            <span className="small"> { t('admin.manage_users.user_created_at', { user }) }</span>
          </Stack>
        </Stack>
      </td>

      <td className="border-0"> {user.email} </td>
      <td className="border-0"> <RoleBadge role={user.role} /> </td>
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />
          <Dropdown.Menu>
            <Dropdown.Item as={Link} to={`/admin/users/edit/${user.id}`}>
              <PencilSquareIcon className="hi-s me-2" />
              {t('view')}
            </Dropdown.Item>
            <Modal
              modalButton={<Dropdown.Item><HomeIcon className="hi-s me-2" />{ t('admin.manage_users.create_room') }</Dropdown.Item>}
              title={t('admin.manage_users.create_new_room')}
              body={<CreateRoomForm mutation={mutationWrapper} userId={user.id} />}
            />
            {/* TODO - samuel: this should have a confirm prompt */}
            <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'banned' })}>
              <NoSymbolIcon className="hi-s me-2" />
              {t('admin.manage_users.ban')}
            </Dropdown.Item>
            <Modal
              modalButton={<Dropdown.Item><TrashIcon className="hi-s me-2" />{ t('delete') }</Dropdown.Item>}
              body={<DeleteUserForm user={user} />}
            />
          </Dropdown.Menu>
        </Dropdown>
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
