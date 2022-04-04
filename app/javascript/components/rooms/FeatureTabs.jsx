import React from 'react';
import { Row, Tabs, Tab } from 'react-bootstrap';
import RecordingsTable from './RecordingsTable';
import Presentation from './Presentation';
import SharedAccess from './SharedAccess';
import RoomSettings from './RoomSettings';

export default function FeatureTabs() {
  return (
    <Row className="py-5">
      <Tabs defaultActiveKey="recordings">
        <Tab eventKey="recordings" title="Recordings">
          <RecordingsTable />
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
