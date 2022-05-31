import React, { useState } from 'react';
import {
  Table, Card, Stack, Button,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import useRoomRecordings from '../../hooks/queries/recordings/useRoomRecordings';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';

export default function RoomRecordings() {
  const [input, setInput] = useState('');
  const { friendlyId } = useParams();
  const { data: recordings } = useRoomRecordings(friendlyId, input);

  return (
    <div className="pt-3 wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-4">
        <div>
          <SearchBarQuery setInput={setInput} />
        </div>
        <Button className="my-2 ms-auto">Re-sync Recordings</Button>
      </Stack>
      <Card className="border-0 shadow-sm p-0 mt-4">
        <RecordingsList recordings={recordings} />
      </Card>
    </div>
  );
}
