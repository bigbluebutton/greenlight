import React from 'react';
import { Row, Col, Button } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import Card from 'react-bootstrap/Card';
import Spinner from '../shared/stylings/Spinner';
import useRoomSettings from '../../hooks/queries/rooms/useRoomSettings';
import useDeleteRoom from '../../hooks/mutations/rooms/useDeleteRoom';
import RoomSettingsRow from './RoomSettingsRow';
import AccessCodes from './AccessCodes';
import Modal from '../shared/Modal';
import DeleteRoomForm from '../forms/DeleteRoomForm';

export default function RoomSettings() {
  const { friendlyId } = useParams();
  const roomSetting = useRoomSettings(friendlyId);

  const mutationWrapper = (args) => useDeleteRoom({ friendlyId, ...args });

  const checkedValue = (settingId) => {
    const { value } = roomSetting.data.find((setting) => setting.name === settingId);

    if (value === 'true' || value === 'ASK_MODERATOR') {
      return true;
    } if (value === 'false' || value === 'ALWAYS_ACCEPT') {
      return false;
    }
    return value;
  };

  if (roomSetting.isLoading) return <Spinner />;

  return (
    <div className="wide-background full-height-room" id="room-settings">
      <Card className="mx-auto mt-3 p-4 border-0 shadow-sm">
        <div className="mt-2">
          <Row>
            <Col className="border-end border-2">
              <Row>
                <h6 className="text-brand">Room Name</h6>
              </Row>
              <AccessCodes />
            </Col>
            <Col className="ps-4">
              <h6 className="text-brand">User Settings</h6>
              <RoomSettingsRow
                settingId="muteOnStart"
                value={checkedValue('muteOnStart')}
                description="Mute users when they join"
              />
              <RoomSettingsRow
                settingId="guestPolicy"
                value={checkedValue('guestPolicy')}
                description="Require moderator approval before joining"
              />
              <RoomSettingsRow
                settingId="glAnyoneCanStart"
                value={checkedValue('glAnyoneCanStart')}
                description="Allow any user to start this meeting"
              />
              <RoomSettingsRow
                settingId="glAnyoneJoinAsModerator"
                value={checkedValue('glAnyoneJoinAsModerator')}
                description="All users join as moderators"
              />
              <RoomSettingsRow
                settingId="record"
                value={checkedValue('record')}
                description="Allow room to be recorded"
              />
            </Col>
          </Row>
          <Row className="float-end">
            <Modal
              modalButton={<Button className="mt-1 mx-2 float-end danger-light-button">Delete Room</Button>}
              title="Delete Room"
              body={<DeleteRoomForm mutation={mutationWrapper} />}
            />
          </Row>
        </div>
      </Card>
    </div>
  );
}
