import React from 'react';
import { Row, Tabs, Tab, Container } from 'react-bootstrap';
import RecordingsTable from './RecordingsTable';
import RoomsList from './RoomsList';

export default function RoomsTabs() {
  return (
    <Container className='p-0 m-0'>
      <Row>
        <Tabs className='rooms-tabs' defaultActiveKey="rooms">
          <Tab eventKey="rooms" title="Rooms">
            <RoomsList />
          </Tab>
          {/* TODO: May need to change this to it's own component depending on how RecordingsTable will work */}
          <Tab eventKey="recordings" title="Recordings">
            <RecordingsTable />
          </Tab>
        </Tabs>
      </Row>
    </Container>
  );
}
