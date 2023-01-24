import React from 'react';
import {
  Tab, Tabs,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import RoomsList from './RoomsList';
import UserRecordings from '../recordings/UserRecordings';
import RecordingsCountTab from '../recordings/RecordingsCountTab';
import useRecordingsCount from '../../hooks/queries/recordings/useRecordingsCount';

export default function Rooms() {
  const { data: recordingsCount } = useRecordingsCount();
  const { t } = useTranslation();
  return (
    <Tabs className="wide-white pt-5" defaultActiveKey="rooms" unmountOnExit>
      <Tab className="background-whitesmoke" eventKey="rooms" title={t('room.rooms')}>
        <RoomsList />
      </Tab>
      <Tab className="background-whitesmoke" eventKey="recordings" title={<RecordingsCountTab count={recordingsCount} />}>
        <UserRecordings />
      </Tab>
    </Tabs>
  );
}
