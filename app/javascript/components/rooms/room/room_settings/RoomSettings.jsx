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
import {
  Row, Col, Button, Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import Card from 'react-bootstrap/Card';
import { useTranslation } from 'react-i18next';
import useRoomSettings from '../../../../hooks/queries/rooms/useRoomSettings';
import useDeleteRoom from '../../../../hooks/mutations/rooms/useDeleteRoom';
import RoomSettingsRow from './RoomSettingsRow';
import Modal from '../../../shared_components/modals/Modal';
import DeleteRoomForm from '../forms/DeleteRoomForm';
import useRoomConfigs from '../../../../hooks/queries/rooms/useRoomConfigs';
import AccessCodeRow from './AccessCodeRow';
import useUpdateRoomSetting from '../../../../hooks/mutations/room_settings/useUpdateRoomSetting';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import UpdateRoomNameForm from './forms/UpdateRoomNameForm';
import useRoom from '../../../../hooks/queries/rooms/useRoom';
import UnshareRoom from './UnshareRoom';
import useServerTags from '../../../../hooks/queries/rooms/useServerTags';
import ServerTagRow from './ServerTagRow';

export default function RoomSettings() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const { friendlyId } = useParams();
  const roomSetting = useRoomSettings(friendlyId);
  const { data: roomConfigs } = useRoomConfigs();
  const { data: room } = useRoom(friendlyId);
  const serverTags = useServerTags(friendlyId);

  const updateMutationWrapper = () => useUpdateRoomSetting(friendlyId);
  const deleteMutationWrapper = (args) => useDeleteRoom({ friendlyId, ...args });

  return (
    <div id="room-settings" className="pt-3">
      <Card className="mx-auto p-4 border-0 card-shadow">
        <div className="mt-2">
          <Row>
            <Col className="border-end border-2">
              <UpdateRoomNameForm friendlyId={friendlyId} />
              <AccessCodeRow
                settingName="glViewerAccessCode"
                updateMutation={updateMutationWrapper}
                code={roomSetting?.data?.glViewerAccessCode}
                config={roomConfigs?.glViewerAccessCode}
                description={t('room.settings.generate_viewers_access_code')}
              />
              <AccessCodeRow
                settingName="glModeratorAccessCode"
                updateMutation={updateMutationWrapper}
                code={roomSetting?.data?.glModeratorAccessCode}
                config={roomConfigs?.glModeratorAccessCode}
                description={t('room.settings.generate_mods_access_code')}
              />
              {(!serverTags.isLoading && Object.keys(serverTags?.data).length !== 0) && (
                <ServerTagRow
                  updateMutation={updateMutationWrapper}
                  currentTag={roomSetting?.data?.serverTag}
                  tagRequired={roomSetting?.data?.serverTagRequired === 'true'}
                  serverTags={serverTags?.data}
                  description={t('room.settings.server_tag')}
                />
              )}
            </Col>
            <Col className="ps-4">
              <Row> <h6 className="text-brand">{ t('room.settings.user_settings') }</h6> </Row>
              {(currentUser?.permissions?.CanRecord === 'true') && (
                <RoomSettingsRow
                  settingName="record"
                  updateMutation={updateMutationWrapper}
                  value={roomSetting?.data?.record}
                  config={roomConfigs?.record}
                  description={t('room.settings.allow_room_to_be_recorded')}
                />
              )}
              <RoomSettingsRow
                settingName="glRequireAuthentication"
                updateMutation={updateMutationWrapper}
                value={roomSetting?.data?.glRequireAuthentication}
                config={roomConfigs?.glRequireAuthentication}
                description={t('room.settings.require_signed_in')}
              />

              <RoomSettingsRow
                settingName="guestPolicy"
                updateMutation={updateMutationWrapper}
                value={roomSetting?.data?.guestPolicy}
                config={roomConfigs?.guestPolicy}
                description={t('room.settings.require_mod_approval')}
                disabled={roomSetting?.data?.glAnyoneJoinAsModerator === 'true'}
              />

              <RoomSettingsRow
                settingName="glAnyoneCanStart"
                updateMutation={updateMutationWrapper}
                value={roomSetting?.data?.glAnyoneCanStart}
                config={roomConfigs?.glAnyoneCanStart}
                description={t('room.settings.allow_any_user_to_start')}
              />
              <RoomSettingsRow
                settingName="glAnyoneJoinAsModerator"
                updateMutation={updateMutationWrapper}
                value={roomSetting?.data?.glAnyoneJoinAsModerator}
                config={roomConfigs?.glAnyoneJoinAsModerator}
                description={t('room.settings.all_users_join_as_mods')}
              />
              <RoomSettingsRow
                settingName="muteOnStart"
                updateMutation={updateMutationWrapper}
                value={roomSetting?.data?.muteOnStart}
                config={roomConfigs?.muteOnStart}
                description={t('room.settings.mute_users_on_join')}
              />
              <div className="float-end mt-3">
                <Stack direction="horizontal" gap={2}>
                  {
                    room.shared
                      && (
                        <Modal
                          modalButton={(
                            <Button
                              variant="delete"
                              className="mt-1 mx-2 float-end"
                            >{t('room.shared_access.delete_shared_access')}
                            </Button>
                          )}
                          body={<UnshareRoom userId={currentUser.id} roomFriendlyId={friendlyId} />}
                        />
                      )
                  }
                  {
                    (!room.shared || currentUser?.permissions?.ManageRooms === 'true')
                      && (
                        <Modal
                          modalButton={(
                            <Button
                              variant="delete"
                              className="mt-1 mx-2 float-end"
                            >{t('room.delete_room')}
                            </Button>
                          )}
                          body={<DeleteRoomForm mutation={deleteMutationWrapper} />}
                        />
                      )
                  }
                </Stack>
              </div>
            </Col>
          </Row>
        </div>
      </Card>
    </div>
  );
}
