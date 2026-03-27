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

import React, { useMemo, useState } from 'react';
import {
  Button, Dropdown,
} from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import {
  ChevronLeftIcon,
  ChevronRightIcon,
  Square2StackIcon,
} from '@heroicons/react/24/outline';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useQueryClient } from 'react-query';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import { localizeDayDateTimeString } from '../../../helpers/DateTimeHelper';
import FeatureTabs from './FeatureTabs';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoom from '../../../hooks/queries/rooms/useRoom';
import useUpdateRoom from '../../../hooks/mutations/rooms/useUpdateRoom';
import useStartMeeting from '../../../hooks/mutations/rooms/useStartMeeting';
import Title from '../../shared_components/utilities/Title';
import useRoomSettings from '../../../hooks/queries/rooms/useRoomSettings';
import {
  ROOM_ICON_OPTIONS,
  getRoomIconKey,
  getRoomVisual,
} from '../../../helpers/RoomVisuals';
import { fileValidation, handleError, IMAGE_SUPPORTED_EXTENSIONS } from '../../../helpers/FileValidationHelper';
import axios from '../../../helpers/Axios';

export default function Room() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const {
    isLoading: isRoomLoading, data: room,
  } = useRoom(friendlyId);
  const startMeeting = useStartMeeting(friendlyId);
  const updateRoom = useUpdateRoom({ friendlyId });
  const queryClient = useQueryClient();
  const currentUser = useAuth();
  const localizedTime = localizeDayDateTimeString(room?.last_session, currentUser?.language);
  const roomSettings = useRoomSettings(friendlyId);
  const language = currentUser?.language === 'tr' ? 'tr' : 'en';
  const [iconPickerOpen, setIconPickerOpen] = useState(false);
  const [roomIconKey, setRoomIconKey] = useState(() => getRoomIconKey(room));
  const roomVisual = useMemo(
    () => getRoomVisual(room ? { ...room, icon_key: roomIconKey } : { icon_key: roomIconKey }),
    [room, roomIconKey],
  );
  const copy = language === 'tr' ? {
    breadcrumb: 'Odalar',
    subtitle: 'Oda performansi, oturum akisi, erisim ve ayarlar tek yerde.',
    live: 'Canli',
    idle: 'Hazir',
    shared: 'Paylasimli',
    privateRoom: 'Ozel',
    participants: 'Katilimci',
    roomId: 'Oda Kimligi',
    lastSession: 'Son oturum',
    noSession: 'Henuz oturum yok',
    loading: 'Oda yukleniyor...',
    copy: 'Baglantiyi Kopyala',
    changeIcon: 'Ikonu degistir',
    uploadThumbnail: 'Gorsel yukle',
    removeThumbnail: 'Yalnizca ikonu kullan',
  } : {
    breadcrumb: 'Rooms',
    subtitle: 'Room performance, sessions, access, and settings in one workspace.',
    live: 'Live',
    idle: 'Ready',
    shared: 'Shared',
    privateRoom: 'Private',
    participants: 'Participants',
    roomId: 'Room ID',
    lastSession: 'Last session',
    noSession: 'No session yet',
    loading: 'Loading room...',
    copy: 'Copy Invite',
    changeIcon: 'Change icon',
    uploadThumbnail: 'Upload thumbnail',
    removeThumbnail: 'Use icon only',
  };

  React.useEffect(() => {
    setRoomIconKey(getRoomIconKey(room));
  }, [room]);

  const applyIconKey = (nextIconKey) => {
    setRoomIconKey(nextIconKey);
    updateRoom.mutate({
      room: {
        icon_key: nextIconKey,
      },
    });
  };

  const onThumbnailChange = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      fileValidation(file, 'image');
      const formData = new FormData();
      formData.append('room[thumbnail_image]', file);
      formData.append('room[icon_key]', roomIconKey);
      await updateRoom.mutateAsync({
        data: formData,
        config: {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        },
      });
      setIconPickerOpen(false);
    } catch (error) {
      handleError(error, t, toast);
    } finally {
      event.target.value = '';
    }
  };

  const purgeThumbnail = async () => {
    try {
      await axios.delete(`/rooms/${friendlyId}/purge_thumbnail_image.json`);
      await queryClient.invalidateQueries(['getRoom', { friendlyId }]);
      await queryClient.invalidateQueries(['getRooms']);
      toast.success(t('toast.success.room.room_updated'));
    } catch (_) {
      toast.error(t('toast.error.problem_completing_action'));
    }
  };

  function copyInvite(role) {
    if (role === 'viewer') {
      navigator.clipboard.writeText(roomSettings?.data?.glViewerAccessCode);
      toast.success(t('toast.success.room.copied_viewer_code'));
    } else if (role === 'moderator') {
      navigator.clipboard.writeText(roomSettings?.data?.glModeratorAccessCode);
      toast.success(t('toast.success.room.copied_moderator_code'));
    } else {
      navigator.clipboard.writeText(`${window.location}/join`);
      toast.success(t('toast.success.room.copied_meeting_url'));
    }
  }

  return (
    <>
      <Title>{room?.name}</Title>
      <div className="ak-room-shell">
        <section className="ak-room-header-card">
          <nav className="ak-room-breadcrumbs" aria-label="Breadcrumb">
            <Link to="/rooms" className="ak-room-breadcrumb-link">
              <ChevronLeftIcon className="ak-room-breadcrumb-back" aria-hidden="true" />
              <span>{copy.breadcrumb}</span>
            </Link>
            <ChevronRightIcon className="ak-room-breadcrumb-separator" aria-hidden="true" />
            <span className="ak-room-breadcrumb-current">{room?.name || copy.loading}</span>
          </nav>

          <div className="ak-room-header-grid">
            <div className="ak-room-header-main">
              <div className="ak-room-title-row">
                <span className="ak-room-visual-pill" aria-hidden="true">
                  {roomVisual.imageUrl ? (
                    <img src={roomVisual.imageUrl} alt="" className="ak-room-visual-pill-image" />
                  ) : roomVisual.emoji}
                </span>
                <h1>{room?.name || copy.loading}</h1>
                <button
                  type="button"
                  className="ak-room-icon-edit-btn"
                  onClick={() => setIconPickerOpen((prev) => !prev)}
                >
                  {copy.changeIcon}
                </button>
              </div>
              <p>{copy.subtitle}</p>

              <div className="ak-room-meta-row">
                <span className={`ak-room-pill ${room?.online ? 'is-live' : 'is-idle'}`}>
                  {room?.online ? copy.live : copy.idle}
                </span>
                <span className="ak-room-pill">
                  {copy.participants}: {room?.participants || 0}
                </span>
                <span className="ak-room-pill">
                  {room?.shared ? copy.shared : copy.privateRoom}
                </span>
                <span className="ak-room-pill">
                  {copy.roomId}: {friendlyId}
                </span>
              </div>

              {iconPickerOpen && (
                <div className="ak-room-icon-editor" role="dialog" aria-label={copy.changeIcon}>
                  {ROOM_ICON_OPTIONS.map((iconOption) => (
                    <button
                      key={iconOption.key}
                      type="button"
                      className={`ak-room-icon-option ${roomIconKey === iconOption.key ? 'is-active' : ''}`}
                      onClick={() => {
                        applyIconKey(iconOption.key);
                        setIconPickerOpen(false);
                      }}
                    >
                      <span aria-hidden="true">{iconOption.emoji}</span>
                      <span>{iconOption.label}</span>
                    </button>
                  ))}
                  <label className="ak-room-icon-option ak-room-icon-upload">
                    <input
                      type="file"
                      accept={IMAGE_SUPPORTED_EXTENSIONS.join(',')}
                      onChange={onThumbnailChange}
                    />
                    <span>{copy.uploadThumbnail}</span>
                  </label>
                  {room?.room_thumbnail_url && (
                    <button
                      type="button"
                      className="ak-room-icon-option"
                      onClick={() => {
                        purgeThumbnail();
                        setIconPickerOpen(false);
                      }}
                    >
                      <span>{copy.removeThumbnail}</span>
                    </button>
                  )}
                </div>
              )}
            </div>

            <div className="ak-room-header-side">
              <div className="ak-room-side-card">
                <span className="ak-room-side-label">
                  {room?.last_session ? copy.lastSession : copy.noSession}
                </span>
                <strong>{room?.last_session ? localizedTime : '--'}</strong>
                <div className="ak-room-side-actions">
                  <Button
                    variant="brand"
                    className="ak-room-primary-action"
                    onClick={startMeeting.mutate}
                    disabled={startMeeting.isLoading || isRoomLoading}
                  >
                    {startMeeting.isLoading && <Spinner className="me-2" />}
                    {room?.online ? t('room.meeting.join_meeting') : t('room.meeting.start_meeting')}
                  </Button>

                  <Dropdown className="ak-room-copy-dropdown">
                    <Button variant="brand-outline" type="button" className="ak-room-copy-main" onClick={() => copyInvite()}>
                      <Square2StackIcon className="hi-s me-1" />
                      {copy.copy}
                    </Button>
                    {(roomSettings?.data?.glModeratorAccessCode || roomSettings?.data?.glViewerAccessCode) && (
                      <Dropdown.Toggle
                        variant="brand-outline"
                        className="ak-room-copy-toggle"
                        id="room-copy-toggle"
                      />
                    )}

                    <Dropdown.Menu className="dropdown-menu">
                      {roomSettings?.data?.glModeratorAccessCode && (
                        <Dropdown.Item onClick={() => copyInvite('moderator')}>
                          {t('copy_moderator_code')}
                        </Dropdown.Item>
                      )}
                      {roomSettings?.data?.glViewerAccessCode && (
                        <Dropdown.Item onClick={() => copyInvite('viewer')}>
                          {t('copy_viewer_code')}
                        </Dropdown.Item>
                      )}
                    </Dropdown.Menu>
                  </Dropdown>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>

      <FeatureTabs room={room} />
    </>
  );
}
