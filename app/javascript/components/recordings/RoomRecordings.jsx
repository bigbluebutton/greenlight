import React, { useState } from 'react';
import {
  Card, Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import useRoomRecordings from '../../hooks/queries/recordings/useRoomRecordings';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';
import useRoomRecordingsProcessing from '../../hooks/queries/recordings/useRoomRecordingsProcessing';

export default function RoomRecordings() {
  const [input, setInput] = useState('');
  const { friendlyId } = useParams();
  const { data: recordings } = useRoomRecordings(friendlyId, input);
  const { data: recordingsProcessing } = useRoomRecordingsProcessing(friendlyId);

  return (
    <div className="wide-background full-height-room">
      <Stack direction="horizontal" className="w-100 mt-3">
        <div>
          <SearchBarQuery setInput={setInput} />
        </div>
      </Stack>
      <Card className="border-0 shadow-sm mt-4">
        <RecordingsList recordings={recordings} recordingsProcessing={recordingsProcessing} />
      </Card>
    </div>
  );
}
