import React from 'react';
import { Row, Tab, Tabs } from 'react-bootstrap';
import RoomsList from './RoomsList';
import Recordings from '../recordings/Recordings';

export default function Rooms() {
  return (
    <Row className="pt-5">
      <Tabs defaultActiveKey="rooms" unmountOnExit>
        <Tab eventKey="rooms" title="Rooms">
          <RoomsList />
        </Tab>
        {/* TODO: May need to change this to it's own component depending on how RecordingsTable will work */}
        <Tab eventKey="recordings" title="Recordings">
          <Recordings />
        </Tab>
      </Tabs>
    </Row>
  );
}
