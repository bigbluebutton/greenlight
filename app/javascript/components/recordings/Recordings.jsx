import React, { useState } from 'react';
import {
  Card, Button, Stack, Container,
} from 'react-bootstrap';
import { Pagination } from 'semantic-ui-react';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from './RecordingsList';
import RoomsRecordingRow from './RoomsRecordingRow';

export default function Recordings() {
  const [input, setInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: recordings } = useRecordings(input, page);
  const recordingsReSync = useRecordingsReSync();

  const handlePage = (e, { activePage }) => {
    const gotopage = { activePage };
    const pagenum = gotopage.activePage;
    setPage(pagenum);
  };

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
        <Container className="text-center">
          <Pagination
            defaultActivePage={recordings.meta.page}
            totalPages={recordings.meta.pages}
            onPageChange={handlePage}
            firstItem={null}
            lastItem={null}
            pointing
            secondary
          />
        </Container>
        )}
    </div>
  );
}
