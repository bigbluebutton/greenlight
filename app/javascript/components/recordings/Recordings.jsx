import React, { useState } from 'react';
import {
  Card, Button, Stack,
} from 'react-bootstrap';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';
import RoomsRecordingRow from './RoomsRecordingRow';
import Spinner from '../shared/stylings/Spinner';

export default function Recordings() {
  const [input, setInput] = useState();
  const [page, setPage] = useState();

  const recordings = useRecordings(input, page);
  const recordingsReSync = useRecordingsReSync();

  if (recordings.isLoading) return <Spinner />;

  const recordingsData = recordings.data.data;
  const recordingsMeta = recordings.data.meta;

  return (
    <div className="wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBarQuery setInput={setInput} />
        </div>
      </Stack>
      <Card className="border-0 shadow-sm p-0 mt-4">
        <RecordingsList
          recordings={recordingsData}
          isLoading={recordings.isLoading}
          RecordingRow={RoomsRecordingRow}
          setPage={setPage}
          recordingsMeta={recordingsMeta}
        />
      </Card>
    </div>
  );
}
