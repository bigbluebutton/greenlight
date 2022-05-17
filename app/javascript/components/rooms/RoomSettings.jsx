import React from 'react';
import { Row, Button, Col } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import Card from 'react-bootstrap/Card';
import Spinner from '../shared/stylings/Spinner';
import useDeleteRoom from '../../hooks/mutations/rooms/useDeleteRoom';
import useRoomSettings from '../../hooks/queries/rooms/useRoomSettings';
import RoomSettingsRow from './RoomSettingsRow';

export default function RoomSettings() {
  const { friendlyId } = useParams();
  const { isLoading, data: settings } = useRoomSettings(friendlyId);
  const { handleDeleteRoom, isLoading: deleteRoomIsLoading } = useDeleteRoom(friendlyId);

  if (isLoading) return <Spinner />;

  function checkedValue(settingId) {
    const { value } = settings.find((setting) => setting.name === settingId);

    if (value === 'true') {
      return true;
    } if (value === 'false') {
      return false;
    }
    return value;
  }

  return (
    <Row className="wide-background full-height-room">
      <Card className="mx-auto my-3 p-4 border-0 shadow-sm">
        <div className="mt-4">
          <Row>
            <Col className="border-end border-2">
              <p>Room Name</p>
            </Col>
            <Col>
              <p>User Settings</p>
              <RoomSettingsRow
                settingId="muteOnStart"
                value={checkedValue('muteOnStart')}
                description="Automatically mute users when they join"
              />
              <RoomSettingsRow
                settingId="glAnyoneCanStart"
                value={checkedValue('glAnyoneCanStart')}
                description="Allow any user to start this room"
              />
            </Col>
          </Row>
          <Row className="float-end">
            <Button id="delete-room" className="mt-1 mx-2 float-end" onClick={handleDeleteRoom}>
              Delete Room
              {deleteRoomIsLoading && <Spinner />}
            </Button>
          </Row>
        </div>
      </Card>
    </Row>
  );
}
