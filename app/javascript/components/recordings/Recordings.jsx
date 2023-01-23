import React, { useState } from 'react';
import {
  Stack,
} from 'react-bootstrap';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBar from '../shared_components/search/SearchBar';
import EmptyRecordingsList from './EmptyRecordingsList';
import RecordingsList from './RecordingsList';

export default function Recordings() {
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: recordings } = useRecordings(searchInput, page);

  if (!isLoading && recordings?.data.length === 0 && !searchInput) {
    return <EmptyRecordingsList />;
  }

  return (
    <div id="user-recordings">
      <Stack direction="horizontal" className="pt-5 w-100">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
      </Stack>
      <RecordingsList recordings={recordings?.data} isLoading={isLoading} setPage={setPage} />
    </div>
  );
}
