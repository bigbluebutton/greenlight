import React, { useState } from 'react';
import {
  Card, Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import useRoomRecordings from '../../hooks/queries/recordings/useRoomRecordings';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';
import useRoomRecordingsProcessing from '../../hooks/queries/recordings/useRoomRecordingsProcessing';
import RoomsRecordingRow from './RoomsRecordingRow';
import Spinner from '../shared/stylings/Spinner';

export default function RoomRecordings() {
  const [input, setInput] = useState('');
  const [page, setPage] = useState();
  const { friendlyId } = useParams();
  const roomRecordings = useRoomRecordings(friendlyId, input, page);
  const roomRecordingsProcessing = useRoomRecordingsProcessing(friendlyId);

  if (roomRecordings.isLoading) return <Spinner />;

  const roomRecordingsData = roomRecordings.data.data;
  const roomRecordingsMeta = roomRecordings.data.meta;

  return (
    <div className="wide-background full-height-room">
      <Stack direction="horizontal" className="w-100 mt-3">
        <div>
          <SearchBarQuery setInput={setInput} />
        </div>
      </Stack>
      <Card className="border-0 shadow-sm mt-4">
        <RecordingsList
          recordings={roomRecordingsData}
          RecordingRow={RoomsRecordingRow}
          recordingsProcessing={roomRecordingsProcessing.data}
          setPage={setPage}
          recordingsMeta={roomRecordingsMeta}
        />
      </Card>
    </div>
  );
}
