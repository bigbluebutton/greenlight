import React from 'react';
import { Row, Col, Button } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import Card from 'react-bootstrap/Card';
import { useTranslation } from 'react-i18next';
import Spinner from '../../../shared_components/utilities/Spinner';
import useRoomSettings from '../../../../hooks/queries/rooms/useRoomSettings';
import useDeleteRoom from '../../../../hooks/mutations/rooms/useDeleteRoom';
import RoomSettingsRow from './RoomSettingsRow';
import Modal from '../../../shared_components/modals/Modal';
import DeleteRoomForm from '../forms/DeleteRoomForm';
import useRoomConfigs from '../../../../hooks/queries/admin/room_configuration/useRoomConfigs';
import AccessCodeRow from './AccessCodeRow';
import useUpdateRoomSetting from '../../../../hooks/mutations/room_settings/useUpdateRoomSetting';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import UpdateRoomNameForm from './forms/UpdateRoomNameForm';

export default function RoomSettings() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const { friendlyId } = useParams();
  const roomSetting = useRoomSettings(friendlyId);
  const roomsConfigs = useRoomConfigs();

  const updateMutationWrapper = () => useUpdateRoomSetting(friendlyId);
  const deleteMutationWrapper = (args) => useDeleteRoom({ friendlyId, ...args });

  if (roomSetting.isLoading || roomsConfigs.isLoading) return <Spinner />;

  return (
    <div id="room-settings">
      <Card className="mx-auto mt-3 p-4 border-0 shadow-sm">
        <div className="mt-2">
          <Row>
            <Col className="border-end border-2">
              <UpdateRoomNameForm friendlyId={friendlyId} />
              <AccessCodeRow
                settingName="glViewerAccessCode"
                updateMutation={updateMutationWrapper}
                code={roomSetting.data.glViewerAccessCode}
                config={roomsConfigs.data.glViewerAccessCode}
                description={t('room.settings.generate_viewers_access_code')}
              />
              <AccessCodeRow
                settingName="glModeratorAccessCode"
                updateMutation={updateMutationWrapper}
                code={roomSetting.data.glModeratorAccessCode}
                config={roomsConfigs.data.glModeratorAccessCode}
                description={t('room.settings.generate_mods_access_code')}
              />
            </Col>
            <Col className="ps-4">
              <Row> <h6 className="text-brand">{ t('room.settings.user_settings') }</h6> </Row>
              {(currentUser.permissions.CanRecord === 'true') && (
                <RoomSettingsRow
                  settingName="record"
                  updateMutation={updateMutationWrapper}
                  value={roomSetting.data.record}
                  config={roomsConfigs.data.record}
                  description={t('room.settings.allow_room_to_be_recorded')}
                />
              )}
              <RoomSettingsRow
                settingName="glRequireAuthentication"
                updateMutation={updateMutationWrapper}
                value={roomSetting.data.glRequireAuthentication}
                config={roomsConfigs.data.glRequireAuthentication}
                description={t('room.settings.require_signed_in')}
              />
              <RoomSettingsRow
                settingName="guestPolicy"
                updateMutation={updateMutationWrapper}
                value={roomSetting.data.guestPolicy}
                config={roomsConfigs.data.guestPolicy}
                description={t('room.settings.require_mod_approval')}
              />
              <RoomSettingsRow
                settingName="glAnyoneCanStart"
                updateMutation={updateMutationWrapper}
                value={roomSetting.data.glAnyoneCanStart}
                config={roomsConfigs.data.glAnyoneCanStart}
                description={t('room.settings.allow_any_user_to_start')}
              />
              <RoomSettingsRow
                settingName="glAnyoneJoinAsModerator"
                updateMutation={updateMutationWrapper}
                value={roomSetting.data.glAnyoneJoinAsModerator}
                config={roomsConfigs.data.glAnyoneJoinAsModerator}
                description={t('room.settings.all_users_join_as_mods')}
              />
              <RoomSettingsRow
                settingName="muteOnStart"
                updateMutation={updateMutationWrapper}
                value={roomSetting.data.muteOnStart}
                config={roomsConfigs.data.muteOnStart}
                description={t('room.settings.mute_users_on_join')}
              />
            </Col>
          </Row>
          <Row className="float-end">
            <Modal
              modalButton={<Button variant="brand-backward" className="mt-1 mx-2 float-end">{ t('room.delete_room') }</Button>}
              title={t('room.delete_room')}
              body={<DeleteRoomForm mutation={deleteMutationWrapper} />}
            />
          </Row>
        </div>
      </Card>
    </div>
  );
}
