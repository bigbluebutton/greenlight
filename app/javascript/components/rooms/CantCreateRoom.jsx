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

import React, { useState } from 'react';
import { Card, Stack } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';

// This page is shown if the user does NOT have the CreateRoom permission
export default function CantCreateRoom() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [meetingUrl, setMeetingUrl] = useState('');

  const handleChange = (event) => {
    setMeetingUrl(event.target.value);
  };

  // Parse the 12 keys friendly id from the input
  const regex = /(\w{3}-\w{3}-\w{3}-\w{3})/;
  const parsedUrl = meetingUrl.match(regex);

  return (
    <div className="vertical-center">
      <Card className="col-md-8 mx-auto border-0 card-shadow">
        <div className="p-5 pb-4">
          <h2><strong>{t('homepage.enter_meeting_url')}</strong></h2>
          <h5>{t('homepage.enter_meeting_url_instruction')}</h5>
        </div>
        <Card.Footer className="bg-white p-0">
          <div className="p-5 pt-4">
            <Stack direction="horizontal" gap={3}>
              <input name="meetingUrl" className="form-control" id="joinUrl" onChange={handleChange} />
              <Button
                onClick={() => navigate(`/rooms/${parsedUrl[1]}/join`, { replace: true })}
                variant="brand"
              >
                { t('join') }
              </Button>
            </Stack>
          </div>
        </Card.Footer>
      </Card>
    </div>
  );
}
