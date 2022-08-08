import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Row, Tab, Container,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';
import RoomConfigRow from './RoomConfigRow';
import useUpdateRoomConfig from '../../hooks/mutations/admin/room_configuration/useUpdateRoomConfig';
import useRoomConfigs from '../../hooks/queries/admin/room_configuration/useRoomConfigs';
import Spinner from '../shared/stylings/Spinner';

export default function RoomConfig() {
  const { data: roomConfigs, isLoading } = useRoomConfigs();

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="room-configuration">
          <Row>
            <Col className="pe-0" sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col className="ps-0" sm={9}>
              <Tab.Content className="p-0">
                <Container className="p-0">
                  <div className="p-4 border-bottom">
                    <h2> Room Configuration </h2>
                  </div>
                  {
                    (isLoading && <Row><Spinner /></Row>) || (
                      <div className="p-4">
                        <RoomConfigRow
                          title="Mute user when they join"
                          subtitle="Automatically mutes the user when they join the BigBlueButtonMeeting"
                          mutation={() => useUpdateRoomConfig('muteOnStart')}
                          value={roomConfigs.muteOnStart}
                        />
                        <RoomConfigRow
                          title="Require moderator approval before joining"
                          subtitle="Prompts the moderator of the BigBlueButton meeting when a user tries to join.
                            If the user is approved, they will be able to join the meeting."
                          mutation={() => useUpdateRoomConfig('guestPolicy')}
                          value={roomConfigs.guestPolicy}
                        />
                        <RoomConfigRow
                          title="Allow any user to start this meeting"
                          subtitle="Allow any user to start the meeting at any time.
                            By default, only the room owner can start the meeting."
                          mutation={() => useUpdateRoomConfig('glAnyoneCanStart')}
                          value={roomConfigs.glAnyoneCanStart}
                        />
                        <RoomConfigRow
                          title="Allow users join as moderators"
                          subtitle="Gives all users moderator priviledge in BigBlueButton when they join the meeting"
                          mutation={() => useUpdateRoomConfig('glAnyoneJoinAsModerator')}
                          value={roomConfigs.glAnyoneJoinAsModerator}
                        />
                        <RoomConfigRow
                          title="Allow room to be recorded"
                          subtitle="Allows room owners to specify whether they want the option to record a room or not.
                            If enabled, the moderator must still click the “Record button once the meeting has started."
                          mutation={() => useUpdateRoomConfig('record')}
                          value={roomConfigs.record}
                        />

                        <RoomConfigRow
                          title="Viewer Access code"
                          subtitle="Allows room owners to have a random alphanumeric code that can be shared with users.
                          The code **if generated** will be required for users to join the room meetings."
                          mutation={() => useUpdateRoomConfig('glViewerAccessCode')}
                          value={roomConfigs.glViewerAccessCode}
                        />

                        <RoomConfigRow
                          title="Moderator access code"
                          subtitle="Allows room owners to have a random alphanumeric code that can be shared with users.
                          The code **if generated** will not be required and when used on any room meeting will join the user as a moderator."
                          mutation={() => useUpdateRoomConfig('glModeratorAccessCode')}
                          value={roomConfigs.glModeratorAccessCode}
                        />
                      </div>
                    )
                  }
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
