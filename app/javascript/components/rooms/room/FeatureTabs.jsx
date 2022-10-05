import React from 'react';
import {Row, Tabs, Tab, Placeholder, Card} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import RoomRecordings from '../../recordings/room_recordings/RoomRecordings';
import Presentation from './presentation/Presentation';
import RoomSettings from './room_settings/RoomSettings';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';
import SharedAccess from './shared_access/SharedAccess';

export default function FeatureTabs() {
  const { t } = useTranslation();
  const { isLoading: isLoadingPreup, data: preuploadEnabled } = useSiteSetting('PreuploadPresentation');
  const { isLoading: isLoadingShare, data: shareRoomEnabled } = useSiteSetting('ShareRooms');

  if(isLoadingPreup || isLoadingShare) {
    return (
      <Row className="pt-4 mx-0">
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={1} size="lg" className="me-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
        </Placeholder>
      </Row>
    )
  }

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
        { shareRoomEnabled
         && (
         <Tab eventKey="access" title={t('room.shared_access.access')}>
           <SharedAccess />
         </Tab>
         )}
        <Tab eventKey="settings" title={t('room.settings.settings')}>
          <RoomSettings />
        </Tab>
      </Tabs>
    </Row>
  );
}
