import React from 'react';
import { Tabs, Tab, Placeholder } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import Presentation from './presentation/Presentation';
import RoomSettings from './room_settings/RoomSettings';
import SharedAccess from './shared_access/SharedAccess';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';
import Recordings from '../../recordings/Recordings';

export default function FeatureTabs({ shared }) {
  const { t } = useTranslation();
  const { isLoading, data: settings } = useSiteSetting(['PreuploadPresentation', 'ShareRooms']);
  const currentUser = useAuth();

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

  // Returns only the Recording tab if the room is a Shared Room and the User does not have the ManageRoom permission
  if (shared && !currentUser?.permissions?.ManageRooms) {
    return (
      <Tabs className="wide-white pt-4 mx-0" defaultActiveKey="recordings" unmountOnExit>
        <Tab className="background-whitesmoke" eventKey="recordings" title={t('recording.recording')}>
          <Recordings />
        </Tab>
      </Tabs>
    );
  }

  return (
    <Tabs className="wide-white pt-4 mx-0" defaultActiveKey="recordings" unmountOnExit>
      <Tab className="background-whitesmoke" eventKey="recordings" title={t('recording.recordings')}>
        <Recordings />
      </Tab>
      {settings?.PreuploadPresentation
        && (
          <Tab className="background-whitesmoke" eventKey="presentation" title={t('room.presentation.presentation')}>
            <Presentation />
          </Tab>
        )}
      {settings?.ShareRooms
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

FeatureTabs.propTypes = {
  shared: PropTypes.bool.isRequired,
};
