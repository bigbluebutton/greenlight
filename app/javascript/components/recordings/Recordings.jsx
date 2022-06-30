import React, { useState } from 'react';
import {
  Card, Button, Stack,
} from 'react-bootstrap';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import useRecordingsReSync from '../../hooks/queries/recordings/useRecordingsReSync';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';

export default function Recordings() {
  const [input, setInput] = useState();
  const [recordings, setRecordings] = useState();
  // TODO: Revisit this.
  useRecordings(input, setRecordings);

  const { refetch: handleRecordingReSync } = useRecordingsReSync();

  return (
    <div className="wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBarQuery setInput={setInput} />
        </div>
        <Button variant="primary-light" className="ms-auto" onClick={handleRecordingReSync}>Re-Sync Recordings</Button>
      </Stack>
      <Card className="border-0 shadow-sm p-0 mt-4">
        <RecordingsList recordings={recordings} />
      </Card>
    </div>
  );
}
