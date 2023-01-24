import React, { useState } from 'react';
import {
  Stack,
} from 'react-bootstrap';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBar from '../shared_components/search/SearchBar';
import EmptyRecordingsList from './EmptyRecordingsList';
import RecordingsList from './RecordingsList';
import NoRecordingsFound from './NoRecordingsFound';

export default function Recordings() {
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: recordings } = useRecordings(searchInput, page);

  if (!isLoading && recordings?.data.length === 0 && !searchInput) {
    return <EmptyRecordingsList />;
  }

  return (
    <div id="user-recordings">
      <Stack direction="horizontal" className="w-100 pt-5">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
      </Stack>
      {
        (searchInput && recordings?.data.length === 0)
          ? (
            <div className="mt-5">
              <NoRecordingsFound searchInput={searchInput} />
            </div>
          ) : (
            <RecordingsList recordings={recordings} isLoading={isLoading} setPage={setPage} />
          )
      }
    </div>
  );
}
