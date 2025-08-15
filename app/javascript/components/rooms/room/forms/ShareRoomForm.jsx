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
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import { Square2StackIcon, CalendarIcon } from '@heroicons/react/24/outline';
import {
  Form, InputGroup, Button, Row, Col,
} from 'react-bootstrap';
import { toast } from 'react-toastify';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import downloadICS from '../../../../helpers/ICSDownloadHelper';
import useEnv from '../../../../hooks/queries/env/useEnv';

export default function ShareRoomForm({ room, roomSettings }) {
  const { t } = useTranslation();
  const { isLoading, data: envData } = useEnv();
  const currentUser = useAuth();

  function roomJoinUrl() {
    if (room.friendly_id !== undefined) {
      return `${window.location}/${room.friendly_id}/join`;
    }
    return `${window.location}/join`;
  }

  function copyInvite(role) {
    if (role === 'viewer') {
      navigator.clipboard.writeText(roomSettings?.data?.glViewerAccessCode);
      toast.success(t('toast.success.room.copied_viewer_code'));
    } else if (role === 'moderator') {
      navigator.clipboard.writeText(roomSettings?.data?.glModeratorAccessCode);
      toast.success(t('toast.success.room.copied_moderator_code'));
    } else {
      navigator.clipboard.writeText(roomJoinUrl());
      toast.success(t('toast.success.room.copied_meeting_url'));
    }
  }

  function copyPhoneNumber() {
    navigator.clipboard.writeText(`${room.voice_bridge_phone_number},,${room.voice_bridge}`);
    toast.success(t('toast.success.room.copied_voice_bridge'));
  }

  function downloadICSFile() {
    downloadICS(currentUser.name, room.name, roomJoinUrl(), room.voice_bridge, room.voice_bridge_phone_number, t, envData.ICS_USE_HTML);
    toast.success(t('toast.success.room.download_ics'));
  }

  return (
    <Form>
      <Form.Group className="mb-3">
        <Form.Label>{t('copy')}</Form.Label>
        <InputGroup>
          <Form.Control
            placeholder={roomJoinUrl()}
            aria-label="link"
            defaultValue={roomJoinUrl()}
            aria-describedby="basic-addon2"
            readOnly
          />
          <Button
            variant="brand-outline"
            onClick={() => copyInvite()}
          >
            <Square2StackIcon className="hi-s mt-0 text-muted" />
          </Button>
        </InputGroup>
      </Form.Group>

      {typeof room.voice_bridge_phone_number !== 'undefined' && typeof room.voice_bridge !== 'undefined' && (
      <Form.Group className="mb-3">
        <Form.Label>{t('copy_voice_bridge')}</Form.Label>
        <InputGroup>
          <Form.Control
            placeholder={`${room.voice_bridge_phone_number},,${room.voice_bridge}`}
            defaultValue={`${room.voice_bridge_phone_number},,${room.voice_bridge}`}
            aria-label="phone"
            aria-describedby="basic-addon2"
            readOnly
          />
          <Button
            variant="brand-outline"
            onClick={() => copyPhoneNumber()}
          >
            <Square2StackIcon className="hi-s mt-0 text-muted" />
          </Button>
        </InputGroup>
      </Form.Group>
      )}

      <Form.Group className="mb-3">
        <Form.Label>{t('room.meeting.download_ics')}</Form.Label>
        <InputGroup>
          <Form.Control
            placeholder={`bbb-meeting-${room.name}.ics`}
            defaultValue={`bbb-meeting-${room.name}.ics`}
            aria-label="ics"
            aria-describedby="basic-addon2"
            readOnly
          />
          <Button
            variant="brand-outline"
            disabled={isLoading}
            onClick={() => downloadICSFile()}
          >
            <CalendarIcon className="hi-s mt-0 text-muted" />
          </Button>
        </InputGroup>
      </Form.Group>

      {(roomSettings?.data?.glModeratorAccessCode || roomSettings?.data?.glViewerAccessCode) && (
      <Row className="mb-3">
        {(roomSettings?.data?.glModeratorAccessCode) && (
        <Form.Group as={Col}>
          <Form.Label>{t('copy_moderator_code')}</Form.Label>
          <InputGroup>
            <Form.Control
              placeholder={roomSettings?.data?.glModeratorAccessCode}
              defaultValue={roomSettings?.data?.glModeratorAccessCode}
              aria-label="Moderator code"
              aria-describedby="basic-addon2"
              readOnly
            />
            <Button
              variant="brand-outline"
              disabled={isLoading}
              onClick={() => copyInvite('moderator')}
            >
              <Square2StackIcon className="hi-s mt-0 text-muted" />
            </Button>
          </InputGroup>
        </Form.Group>
        )}

        {(roomSettings?.data?.glViewerAccessCode) && (
        <Form.Group as={Col}>
          <Form.Label>{t('copy_viewer_code')}</Form.Label>
          <InputGroup>
            <Form.Control
              placeholder={roomSettings?.data?.glViewerAccessCode}
              defaultValue={roomSettings?.data?.glViewerAccessCode}
              aria-label="Viewer Code"
              aria-describedby="basic-addon2"
              readOnly
            />
            <Button
              variant="brand-outline"
              disabled={isLoading}
              onClick={() => copyInvite('viewer')}
            >
              <Square2StackIcon className="hi-s mt-0 text-muted" />
            </Button>
          </InputGroup>
        </Form.Group>
        )}
      </Row>
      )}
    </Form>
  );
}

ShareRoomForm.propTypes = {
  room: PropTypes.shape({
    id: PropTypes.string.isRequired,
    friendly_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    voice_bridge_phone_number: PropTypes.string,
    voice_bridge: PropTypes.string,
    last_session: PropTypes.string,
    shared_owner: PropTypes.string,
    online: PropTypes.bool,
    participants: PropTypes.number,
  }).isRequired,

  roomSettings: PropTypes.shape({
    data: PropTypes.shape({
      glModeratorAccessCode: PropTypes.string,
      glViewerAccessCode: PropTypes.string,
    }).isRequired,
  }).isRequired,
};
