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
    <div className="pt-3">
      <RecordingsList
        recordings={roomRecordings}
        isLoading={isLoading}
        setPage={setPage}
        setSearchInput={setSearchInput}
        searchInput={searchInput}
        recordingsProcessing={roomRecordingsProcessing}
      />
    </div>
  );
}
