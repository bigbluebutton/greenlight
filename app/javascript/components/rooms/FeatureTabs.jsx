import React from 'react';
import { Row, Tabs, Tab } from 'react-bootstrap';
import RoomRecordings from '../recordings/RoomRecordings';
import Presentation from './Presentation';
import SharedAccess from '../shared_accesses/SharedAccess';
import RoomSettings from '../room_settings/RoomSettings';

export default function FeatureTabs() {
  return (
    <Row className="pt-5 mx-0">
      <Tabs defaultActiveKey="recordings">
        <Tab eventKey="recordings" title="Recordings">
          <RoomRecordings />
        </Tab>
        <Tab eventKey="presentation" title="Presentation">
          <Presentation />
        </Tab>
        <Tab eventKey="access" title="Access">
          <SharedAccess />
        </Tab>
        <Tab eventKey="settings" title="Settings">
          <RoomSettings />
        </Tab>
      </Tabs>
    </Row>
  );
}
