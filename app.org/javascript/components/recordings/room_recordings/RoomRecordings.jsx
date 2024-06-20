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
import { useParams } from 'react-router-dom';
import useRoomRecordings from '../../../hooks/queries/recordings/useRoomRecordings';
import RecordingsList from '../RecordingsList';
import useRoomRecordingsProcessing from '../../../hooks/queries/recordings/useRoomRecordingsProcessing';

export default function RoomRecordings() {
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { friendlyId } = useParams();
  const { isLoading, data: roomRecordings } = useRoomRecordings(friendlyId, searchInput, page);
  const roomRecordingsProcessing = useRoomRecordingsProcessing(friendlyId);

  return (
    <div id="room-recordings">
      <RecordingsList
        recordings={roomRecordings}
        isLoading={isLoading}
        setPage={setPage}
        setSearchInput={setSearchInput}
        searchInput={searchInput}
        recordingsProcessing={roomRecordingsProcessing.data}
        numPlaceholders={3}
      />
    </div>
  );
}
