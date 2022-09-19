import React from 'react';
import { Row, Tabs, Tab } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import RoomRecordings from '../../recordings/room_recordings/RoomRecordings';
import Presentation from './presentation/Presentation';
import RoomSettings from './room_settings/RoomSettings';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';

export default function FeatureTabs() {
  const { t } = useTranslation();
  const { data: preuploadEnabled } = useSiteSetting('PreuploadPresentation');

  return (
    <Row className="pt-4 mx-0">
      <Tabs defaultActiveKey="recordings" unmountOnExit>
        <Tab eventKey="recordings" title={t('recording.recording')}>
          <RoomRecordings />
        </Tab>
        { preuploadEnabled
          && (
          <Tab eventKey="presentation" title={t('room.presentation.presentation')}>
            <Presentation />
          </Tab>
          )}
        {/* { shareRoomEnabled */}
        {/*  && ( */}
        {/*  <Tab eventKey="access" title={t('room.shared_access.access)}> */}
        {/*    <SharedAccess /> */}
        {/*  </Tab> */}
        {/*  )} */}
        <Tab eventKey="settings" title={t('room.settings.settings')}>
          <RoomSettings />
        </Tab>
      </Tabs>
    </Row>
  );
}
