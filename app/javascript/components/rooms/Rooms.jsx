import React from 'react';
import {
  Spinner, Tab, Tabs,
} from 'react-bootstrap';
import RoomsList from './RoomsList';
import Recordings from '../recordings/Recordings';
import RecordingsCountTab from '../recordings/RecordingsCountTab';
import useRecordingsCount from '../../hooks/queries/recordings/useRecordingsCount';

export default function Rooms() {
  const { isLoading, data: recordingsCount } = useRecordingsCount();

  if (isLoading) return <Spinner />;

  return (
    <div className="pt-5 wide-background-rooms">
      <Tabs defaultActiveKey="rooms" unmountOnExit>
        <Tab eventKey="rooms" title="Rooms">
          <RoomsList />
        </Tab>
        {/* TODO: May need to change this to it's own component depending on how RecordingsTable will work */}
        <Tab eventKey="recordings" title={<RecordingsCountTab count={recordingsCount} />}>
          <Recordings />
        </Tab>
      </Tabs>
    </div>
  );
}
