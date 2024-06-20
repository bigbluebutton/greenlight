// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
import useRoomConfigValue from '../../../hooks/queries/rooms/useRoomConfigValue';

export default function FeatureTabs() {
  const { t } = useTranslation();
  const { isLoading, data: settings } = useSiteSetting(['PreuploadPresentation', 'ShareRooms']);
  const currentUser = useAuth();

  const { friendlyId } = useParams();
  const { data: room } = useRoom(friendlyId);
  const { isLoading: isRoomConfigLoading, data: recordValue } = useRoomConfigValue('record');

  if (isLoading || isRoomConfigLoading) {
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

  const showRecTabs = (recordValue !== 'false');

  return (
    <Tabs className="wide-white pt-4 mx-0" defaultActiveKey={showRecTabs ? 'recordings' : 'presentation'} unmountOnExit>
      {showRecTabs
        && (
          <Tab className="background-whitesmoke" eventKey="recordings" title={t('recording.recordings')}>
            <RoomRecordings />
          </Tab>
        )}
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
