import React, { useState } from 'react';
import {
  Card, Button, Stack, Container,
} from 'react-bootstrap';
import { Pagination } from 'semantic-ui-react';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';
import RoomsRecordingRow from './RoomsRecordingRow';
import Pagy from '../shared/Pagy';

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
      </Card>
      {!isLoading
        && (
        <Pagy
          page={recordings.meta.page}
          totalPages={recordings.meta.pages}
          setPage={setPage}
        />
        )}
    </div>
  );
}
