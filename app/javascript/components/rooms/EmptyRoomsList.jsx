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
import { Button, Card } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Modal from '../shared_components/modals/Modal';
import CreateRoomForm from './room/forms/CreateRoomForm';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import UserBoardIcon from './UserBoardIcon';

export default function EmptyRoomsList() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUser.id, ...args });

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
      || ManageRoles === 'true'
      || currentUser?.isSuperAdmin) {
      return true;
    }

    return false;
  };

  return (
    <div id="rooms-list-empty" className="pt-3">
      <Card className="border-0 card-shadow text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UserBoardIcon className="hi-l text-brand d-block mx-auto" />
          </div>
          <Card.Title className="text-brand"> { t('room.rooms_list_is_empty') }</Card.Title>
          {
            adminAccess() &&
            <Card.Text>
              { t('room.rooms_list_empty_create_room') }
            </Card.Text>
          }
          {
            adminAccess() &&
            <Modal
              modalButton={<Button variant="brand" className="ms-auto me-xxl-1">{ t('room.add_new_room') }</Button>}
              title={t('room.create_new_room')}
              body={<CreateRoomForm mutation={mutationWrapper} userId={currentUser.id} />}
            />
          }
        </Card.Body>
      </Card>
    </div>
  );
}
