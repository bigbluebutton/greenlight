import React from 'react';
import PropTypes from 'prop-types';
import {
  Stack, Dropdown,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import {
  CheckCircleIcon,
  CheckIcon,
  EllipsisVerticalIcon,
  XCircleIcon,
} from '@heroicons/react/24/outline';
import Avatar from '../../users/user/Avatar';
import useUpdateUserStatus from '../../../hooks/mutations/admin/manage_users/useUpdateUserStatus';
import { localizeDateTimeString } from '../../../helpers/DateTimeHelper';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function BannedPendingRow({ user, pendingTable }) {
  const { t } = useTranslation();
  const updateUserStatus = useUpdateUserStatus();
  const currentUser = useAuth();
  const localizedTime = localizeDateTimeString(currentUser?.created_at, currentUser?.language);

  return (
    <tr key={user.id} className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack direction="horizontal">
          <div className="me-2">
            <Avatar avatar={user.avatar} size="small" />
          </div>
          <Stack>
            <span className="text-dark fw-bold"> {user.name} </span>
            <span className="small"> { localizedTime }</span>
          </Stack>
        </Stack>
      </td>

      <td className="border-0"> {user.email} </td>
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />
          <Dropdown.Menu>
            {pendingTable ? (
              <>
                <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'active' })}>
                  <CheckCircleIcon className="hi-s me-2" />
                  {t('admin.manage_users.approve')}
                </Dropdown.Item>
                <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'banned' })}>
                  <XCircleIcon className="hi-s me-2" />
                  {t('admin.manage_users.decline')}
                </Dropdown.Item>
              </>
            ) : (
              <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'active' })}>
                <CheckIcon className="hi-s me-2" />
                {t('admin.manage_users.unban')}
              </Dropdown.Item>
            )}
          </Dropdown.Menu>
        </Dropdown>
      </td>
    </tr>
  );
}

BannedPendingRow.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    language: PropTypes.string.isRequired,
  }).isRequired,
  pendingTable: PropTypes.bool.isRequired,
};
