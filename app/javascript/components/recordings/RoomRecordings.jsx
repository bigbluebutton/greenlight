import React, { useState } from 'react';
import {
  Card, Stack, Container,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import { Pagination } from 'semantic-ui-react';
import useRoomRecordings from '../../hooks/queries/recordings/useRoomRecordings';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';
import useRoomRecordingsProcessing from '../../hooks/queries/recordings/useRoomRecordingsProcessing';
import RoomsRecordingRow from './RoomsRecordingRow';
import Pagy from '../shared/Pagy';

export default function RoomRecordings() {
  const [input, setInput] = useState('');
  const [page, setPage] = useState();
  const { friendlyId } = useParams();
  const { isLoading, data: roomRecordings } = useRoomRecordings(friendlyId, input, page);
  const roomRecordingsProcessing = useRoomRecordingsProcessing(friendlyId);

  const handlePage = (e, { activePage }) => {
    const gotopage = { activePage };
    const pagenum = gotopage.activePage;
    setPage(pagenum);
  };

  return (
    <div className="wide-background full-height-room">
      <Stack direction="horizontal" className="w-100 mt-3">
        <div>
          <SearchBarQuery setInput={setInput} />
        </div>
      </Stack>
      <Card className="border-0 shadow-sm mt-4">
        <RecordingsList
          recordings={roomRecordings?.data}
          RecordingRow={RoomsRecordingRow}
          recordingsProcessing={roomRecordingsProcessing.data}
        />
      </Card>
      {!isLoading
        && (
        <Pagy
          page={roomRecordings.meta.page}
          totalPages={roomRecordings.meta.pages}
          setPage={setPage}
        />
        )}
    </div>
  );
}
