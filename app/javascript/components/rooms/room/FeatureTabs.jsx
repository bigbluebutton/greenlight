import React from 'react';
import { Tabs, Tab, Placeholder } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';
import Presentation from './presentation/Presentation';
import RoomSettings from './room_settings/RoomSettings';
import SharedAccess from './shared_access/SharedAccess';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';
import RoomRecordings from '../../recordings/room_recordings/RoomRecordings';
import useRoom from '../../../hooks/queries/rooms/useRoom';

export default function FeatureTabs() {
  const { t } = useTranslation();
  const { isLoading, data: settings } = useSiteSetting(['PreuploadPresentation', 'ShareRooms']);
  const currentUser = useAuth();

  const { friendlyId } = useParams();
  const { data: room } = useRoom(friendlyId);

  if (isLoading) {
    return (
      <div className="wide-white pt-4 pb-2 mx-0">
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={1} size="lg" className="me-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
        </Placeholder>
      </div>
    );
  }

  return (
    <Tabs className="wide-white pt-4 mx-0" defaultActiveKey="recordings" unmountOnExit>
      <Tab className="background-whitesmoke" eventKey="recordings" title={t('recording.recordings')}>
        <RoomRecordings />
      </Tab>
      {settings?.PreuploadPresentation
        && (
          <Tab className="background-whitesmoke" eventKey="presentation" title={t('room.presentation.presentation')}>
            <Presentation />
          </Tab>
        )}
      {(settings?.ShareRooms && (!room?.shared || currentUser?.permissions?.ManageRooms === 'true'))
        && (
          <Tab className="background-whitesmoke" eventKey="access" title={t('room.shared_access.access')}>
            <SharedAccess />
          </Tab>
        )}
      <Tab className="background-whitesmoke" eventKey="settings" title={t('room.settings.settings')}>
        <RoomSettings />
      </Tab>
    </Tabs>
  );
}
