import React, { useState } from 'react';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import RecordingsList from './RecordingsList';

export default function UserRecordings() {
  const [page, setPage] = useState();
  const [searchInput, setSearchInput] = useState();
  const { isLoading, data: recordings } = useRecordings(searchInput, page);

  return (
    <div id="user-recordings" className="pt-5">
      <RecordingsList
        recordings={recordings}
        isLoading={isLoading}
        setPage={setPage}
        setSearchInput={setSearchInput}
        searchInput={searchInput}
      />
    </div>
  );
}
