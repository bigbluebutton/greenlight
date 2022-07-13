import React, { useState } from 'react';
import {
  Card, Button, Stack,
} from 'react-bootstrap';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import useRecordingsReSync from '../../hooks/queries/recordings/useRecordingsReSync';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';
import RoomsRecordingRow from './RoomsRecordingRow';

export default function Recordings() {
  const [input, setInput] = useState();
  // TODO: Revisit this.
  const recordings = useRecordings(input);

  const recordingsReSync = useRecordingsReSync();

  return (
    <div className="wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBarQuery setInput={setInput} />
        </div>
        <Button variant="primary-light" className="ms-auto" onClick={recordingsReSync.refetch}>Re-Sync Recordings</Button>
      </Stack>
      <Card className="border-0 shadow-sm p-0 mt-4">
        <RecordingsList
          recordings={recordings.data}
          isLoading={recordings.isLoading}
          RecordingRow={RoomsRecordingRow}
        />
      </Card>
    </div>
  );
}
