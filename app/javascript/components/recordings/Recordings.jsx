import React, { useState } from 'react';
import {
  Card, Stack,
} from 'react-bootstrap';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBarQuery from '../shared_components/search/SearchBarQuery';
import RecordingsList from './RecordingsList';
import RoomsRecordingRow from './room_recordings/RoomsRecordingRow';
import Pagination from '../shared_components/Pagination';

export default function Recordings() {
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: recordings } = useRecordings(searchInput, page);

  return (
    <>
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBarQuery searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
      </Stack>
      <Card className="border-0 shadow-sm p-0 mt-4">
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
    </>
  );
}
