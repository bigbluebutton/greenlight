import React from 'react';
import { Row, Tab, Tabs } from 'react-bootstrap';
import { Navigate } from 'react-router-dom';
import RoomsList from './RoomsList';
import Recordings from '../recordings/Recordings';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function Rooms() {
  const currentUser = useAuth();

  if (currentUser.permissions?.CreateRoom !== 'true') {
    return <Navigate to="/" />;
  }

  return (
    <Row className="pt-5 wide-background-rooms">
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
