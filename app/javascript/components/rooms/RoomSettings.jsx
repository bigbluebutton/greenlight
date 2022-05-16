import React from 'react';
import { Row, Button, Col } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import Card from 'react-bootstrap/Card';
import Spinner from '../shared/stylings/Spinner';
import useDeleteRoom from '../../hooks/mutations/rooms/useDeleteRoom';
import useUpdateRoomSetting from '../../hooks/mutations/room_settings/useUpdateRoomSetting';

export default function RoomSettings() {
  const { friendlyId } = useParams();
  const { handleDeleteRoom, isLoading: deleteRoomIsLoading } = useDeleteRoom(friendlyId);
  const { handleUpdateRoomSetting } = useUpdateRoomSetting(friendlyId);

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
              <span className="text-muted">
                <label className="form-check-label me-5" htmlFor="muteOnStart">
                  Automatically mute users when they join
                  <div className="form-switch d-inline-block ms-5">
                    <input
                      className="form-check-input text-primary"
                      type="checkbox"
                      id="muteOnStart"
                      onClick={(event) => {
                        handleUpdateRoomSetting({ settingName: 'muteOnStart', settingValue: event.target.checked });
                      }}
                    />
                  </div>
                </label>
              </span>
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
