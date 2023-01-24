import React, { useState } from 'react';
import {
  Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import useRoomRecordings from '../../../hooks/queries/recordings/useRoomRecordings';
import SearchBar from '../../shared_components/search/SearchBar';
import RecordingsList from '../RecordingsList';
import useRoomRecordingsProcessing from '../../../hooks/queries/recordings/useRoomRecordingsProcessing';
import EmptyRecordingsList from '../EmptyRecordingsList';
import NoRecordingsFound from '../NoRecordingsFound';

export default function RoomRecordings() {
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { friendlyId } = useParams();
  const { isLoading, data: roomRecordings } = useRoomRecordings(friendlyId, searchInput, page);
  const roomRecordingsProcessing = useRoomRecordingsProcessing(friendlyId);

  if (!isLoading && roomRecordings?.data.length === 0 && !searchInput) {
    return <EmptyRecordingsList />;
  }

  return (
    <div id="user-recordings">
      <Stack direction="horizontal" className="w-100 pt-3">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
      </Stack>
      {
        (searchInput && roomRecordings?.data.length === 0)
          ? (
            <div className="mt-5">
              <NoRecordingsFound searchInput={searchInput} />
            </div>
          ) : (
            <RecordingsList recordings={roomRecordings} isLoading={isLoading} recordingsProcessing={roomRecordingsProcessing} setPage={setPage} />
          )
      }
    </div>
  );
}
