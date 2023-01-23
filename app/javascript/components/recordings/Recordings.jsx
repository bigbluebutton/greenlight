import React, { useState } from 'react';
import {
  Card, Stack, Table,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import SearchBar from '../shared_components/search/SearchBar';
import Pagination from '../shared_components/Pagination';
import SortBy from '../shared_components/search/SortBy';
import RecordingsListRowPlaceHolder from './RecordingsListRowPlaceHolder';
import NoRecordingsFound from './NoRecordingsFound';
import EmptyRecordingsList from './EmptyRecordingsList';
import RoomsRecordingRow from './room_recordings/RoomsRecordingRow';

export default function Recordings() {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState('');
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
      {
        (searchInput && recordings?.data.length === 0)
          ? (
            <div className="mt-5">
              <NoRecordingsFound searchInput={searchInput} />
            </div>
          )
          : (
            <Card className="border-0 shadow-sm p-0 mt-4 mb-5">
              <Table id="recordings-table" className="table-bordered border border-2 mb-0 recordings-list" hover responsive>
                <thead>
                  <tr className="text-muted small">
                    <th className="fw-normal border-end-0">{t('recording.name')}<SortBy fieldName="name" /></th>
                    <th className="fw-normal border-0">{t('recording.length')}<SortBy fieldName="length" /></th>
                    <th className="fw-normal border-0">{t('recording.users')}</th>
                    <th className="fw-normal border-0">{t('recording.visibility')}<SortBy fieldName="visibility" /></th>
                    <th className="fw-normal border-0">{t('recording.formats')}</th>
                    <th className="border-start-0" aria-label="options" />
                  </tr>
                </thead>
                <tbody className="border-top-0">
                  {
                    (isLoading && [...Array(7)].map((val, idx) => (
                      // eslint-disable-next-line react/no-array-index-key
                      <RecordingsListRowPlaceHolder key={idx} />
                    )))
                    || (recordings?.data.length && recordings?.data.map((recording) => (
                      <RoomsRecordingRow key={recording.id} recording={recording} />
                    )))
                  }
                </tbody>
              </Table>
              {!isLoading
                && (
                  <Pagination
                    page={recordings.meta.page}
                    totalPages={recordings.meta.pages}
                    setPage={setPage}
                  />
                )}
            </Card>
          )
      }
    </div>
  );
}
