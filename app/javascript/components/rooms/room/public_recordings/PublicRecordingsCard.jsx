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

/* eslint-disable consistent-return */
import React from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import PublicRecordingsList from './PublicRecordingsList';

export default function PublicRecordingsCard() {
  const { friendlyId } = useParams();

  return (
    <Card className="mx-auto p-0 border-0 card-shadow">
      <Card.Body className="pt-4 px-5">
        <PublicRecordingsList friendlyId={friendlyId} />
      </Card.Body>
    </Card>
  );
}
