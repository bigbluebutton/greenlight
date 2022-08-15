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
  const [input, setInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: recordings } = useRecordings(input, page);

  return (
    <div className="wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBarQuery setInput={setInput} />
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
    </div>
  );
}
