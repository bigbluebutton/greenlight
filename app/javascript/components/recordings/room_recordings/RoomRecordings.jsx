import React, { useState } from 'react';
import {
  Card, Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import useRoomRecordings from '../../../hooks/queries/recordings/useRoomRecordings';
import SearchBar from '../../shared_components/search/SearchBar';
import RecordingsList from '../RecordingsList';
import useRoomRecordingsProcessing from '../../../hooks/queries/recordings/useRoomRecordingsProcessing';
import RoomsRecordingRow from './RoomsRecordingRow';
import Pagination from '../../shared_components/Pagination';

export default function RoomRecordings() {
  const [searchInput, setSearchInput] = useState('');
  const [page, setPage] = useState();
  const { friendlyId } = useParams();
  const { isLoading, data: roomRecordings } = useRoomRecordings(friendlyId, searchInput, page);
  const roomRecordingsProcessing = useRoomRecordingsProcessing(friendlyId);

  return (
    <>
      <Stack direction="horizontal" className="w-100 mt-3">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
      </Stack>
      <Card className="border-0 shadow-sm mt-4 mb-5">
        <RecordingsList
          recordings={roomRecordings?.data}
          RecordingRow={RoomsRecordingRow}
          recordingsProcessing={roomRecordingsProcessing.data}
        />
      </Card>
      {!isLoading
        && (
        <Pagination
          page={roomRecordings.meta.page}
          totalPages={roomRecordings.meta.pages}
          setPage={setPage}
        />
        )}
    </>
  );
}
