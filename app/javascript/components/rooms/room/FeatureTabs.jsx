import React from 'react';
import {
  Row, Tabs, Tab, Placeholder,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import RoomRecordings from '../../recordings/room_recordings/RoomRecordings';
import Presentation from './presentation/Presentation';
import RoomSettings from './room_settings/RoomSettings';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';
import SharedAccess from './shared_access/SharedAccess';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function FeatureTabs({ shared }) {
  const { t } = useTranslation();
  const { isLoading: isLoadingPreup, data: preuploadEnabled } = useSiteSetting('PreuploadPresentation');
  const { isLoading: isLoadingShare, data: shareRoomEnabled } = useSiteSetting('ShareRooms');

  const currentUser = useAuth();

  if (isLoadingPreup || isLoadingShare) {
    return (
      <Row className="pt-4 mx-0">
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={1} size="lg" className="me-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
          <Placeholder xs={1} size="lg" className="mx-2" />
        </Placeholder>
      </Row>
    );
  }

  // Returns only the Recording tab if the room is a Shared Room and the User does not have the ManageRoom permission
  if (shared && !currentUser?.permissions?.ManageRooms) {
    return (
      <Row className="pt-4 mx-0">
        <Tabs defaultActiveKey="recordings" unmountOnExit>
          <Tab eventKey="recordings" title={t('recording.recording')}>
            <RoomRecordings />
          </Tab>
        </Tabs>
      </Row>
    );
  }

  return (
    <Row className="pt-4 mx-0">
      <Tabs defaultActiveKey="recordings" unmountOnExit>
        <Tab eventKey="recordings" title={t('recording.recordings')}>
          <RoomRecordings />
        </Tab>
        {preuploadEnabled
          && (
            <Tab eventKey="presentation" title={t('room.presentation.presentation')}>
              <Presentation />
            </Tab>
          )}
        {shareRoomEnabled
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

FeatureTabs.propTypes = {
  shared: PropTypes.bool.isRequired,
};
