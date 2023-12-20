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
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import { Form, InputGroup, Button } from 'react-bootstrap';
import { toast } from 'react-toastify';
import { downloadICS } from '../../../../helpers/ICSDownloadHelper';



export default function ShareRoomForm({ room, friendly_id }) {
  const { t } = useTranslation();
  const currentUser = useAuth();

  function roomJoinUrl(){
    console.log(room);
    return `https://${window.location.hostname}/rooms/${friendly_id}/join`; 
  }

  function copyInvite() {
    navigator.clipboard.writeText(roomJoinUrl());
    toast.success(t('toast.success.room.copied_meeting_url'));
  }

  function copyPhoneNumber() {
    navigator.clipboard.writeText(`${room.voice_bridge_phone_number},,${room.voice_bridge}`);
    toast.success(t('toast.success.room.copied_voice_bridge'));
  }

  function downloadICSFile(){
    downloadICS(currentUser.name, room.name, roomJoinUrl(), room.voice_bridge, room.voice_bridge_phone_number, t);
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

      {typeof room.voice_bridge_phone_number !== 'undefined' && typeof room.voice_bridge !== 'undefined' && <Form.Group className="mb-3">
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
      </Form.Group>}

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
            onClick={() => downloadICSFile()}
          >
            <CalendarIcon className="hi-s mt-0 text-muted" />
          </Button>
        </InputGroup>
      </Form.Group>
    </Form>
  );
}

ShareRoomForm.defaulProps = {
  room: PropTypes.shape({
    last_session: '',
  }),
};

ShareRoomForm.propTypes = {
  friendly_id: PropTypes.string.isRequired,
  room: PropTypes.shape({
    id: PropTypes.string.isRequired,
    friendly_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    last_session: PropTypes.string,
    shared_owner: PropTypes.string,
    online: PropTypes.bool,
    participants: PropTypes.number,
  }).isRequired,
};