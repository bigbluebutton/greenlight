import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Row, Tab, Stack, Container,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';
import RoomConfigRow from './RoomConfigRow';
import useUpdateRoomConfig from '../../hooks/mutations/admins/room-configuration/useUpdateRoomConfig';
import useRoomConfigs from '../../hooks/queries/admin/room-configuration/useRoomConfigs';
import Spinner from '../shared/stylings/Spinner';

export default function RoomConfig() {
  const { data: roomConfigs, isLoading } = useRoomConfigs();

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="room-configuration">
          <Row>
            <Col sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Container>
                  <Row>
                    <Stack direction="horizontal" className="w-100 mt-4">
                      <h3 className="mb-4"> Room Configuration </h3>
                    </Stack>
                    <hr className="solid" />
                  </Row>
                  {
                    (isLoading && <Row><Spinner /></Row>) || (
                      <Row>
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
                      </Row>
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
