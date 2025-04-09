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

export default function BannedPendingRow({ user, tableType }) {
  const { t } = useTranslation();
  const updateUserStatus = useUpdateUserStatus();
  const currentUser = useAuth();
  const localizedTime = localizeDateTimeString(user?.created_at, currentUser?.language);

  const renderDropdownItems = () => {
    if (tableType === 'pending') {
      return (
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
      );
    }
    if (tableType === 'banned') {
      return (
        <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'active' })}>
          <CheckIcon className="hi-s me-2" />
          {t('admin.manage_users.unban')}
        </Dropdown.Item>
      );
    }
    if (tableType === 'unverified') {
      return (
        <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, verified: true })}>
          <CheckIcon className="hi-s me-2" />
          {t('admin.manage_users.verify')}
        </Dropdown.Item>
      );
    }
  };

  return (
    <tr key={user.id} className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack direction="horizontal">
          <div className="me-2">
            <Avatar avatar={user.avatar} size="small" />
          </div>
          <Stack>
            <span className="text-dark fw-bold"> {user.name} </span>
            <span className="small"> { t('admin.manage_users.user_created_at', { localizedTime }) }</span>
          </Stack>
        </Stack>
      </td>

      <td className="border-0"> {user.email} </td>
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />
          <Dropdown.Menu>
            {renderDropdownItems()}
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
  tableType: PropTypes.string.isRequired,
};
