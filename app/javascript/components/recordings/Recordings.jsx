import React, { useState } from 'react';
import {
  Card, Stack,
} from 'react-bootstrap';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBar from '../shared_components/search/SearchBar';
import RecordingsList from './RecordingsList';
import RoomsRecordingRow from './room_recordings/RoomsRecordingRow';
import Pagination from '../shared_components/Pagination';

export default function Recordings() {
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: recordings } = useRecordings(searchInput, page);

  return (
    <div id="user-recordings">
      <Stack direction="horizontal" className="w-100 pt-5">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
      </Stack>
      <Card className="border-0 shadow-sm p-0 mt-4 mb-5">
        <RecordingsList
          recordings={recordings?.data}
          isLoading={isLoading}
          RecordingRow={RoomsRecordingRow}
        />
        {!isLoading
          && (
            <Pagination
              page={recordings.meta.page}
              totalPages={recordings.meta.pages}
              setPage={setPage}
            />
          )}
      </Card>
    </div>
  );
}
