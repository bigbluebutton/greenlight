import React from 'react';
import { Row, Tabs, Tab } from 'react-bootstrap';
import RoomRecordings from '../recordings/RoomRecordings';
import Presentation from './Presentation';
import SharedAccess from './SharedAccess';
import RoomSettings from './RoomSettings';

export default function FeatureTabs() {
  return (
    <Row className="py-5 w-100">
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
