import React from 'react';
import PropTypes from 'prop-types';
import { Card, Stack, Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import SortBy from '../shared_components/search/SortBy';
import RecordingsListRowPlaceHolder from './RecordingsListRowPlaceHolder';
import NoRecordingsFound from './NoRecordingsFound';
import RoomsRecordingRow from './room_recordings/RoomsRecordingRow';
import Pagination from '../shared_components/Pagination';
import EmptyRecordingsList from './EmptyRecordingsList';
import SearchBar from '../shared_components/search/SearchBar';

export default function RecordingsList({
  recordings, isLoading, setPage, searchInput, setSearchInput, recordingsProcessing,
}) {
  const { t } = useTranslation();

  if (!isLoading && recordings?.data?.length === 0 && !searchInput) {
    return <EmptyRecordingsList />;
  }

  return (
    <>
      <Stack direction="horizontal" className="w-100">
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
                  || (recordings?.data?.length && recordings?.data?.map((recording) => (
                    <RoomsRecordingRow key={recording.id} recording={recording} />
                  )))
                }
                </tbody>
              </Table>
              {!isLoading
                && (
                  <Pagination
                    page={recordings?.meta?.page}
                    totalPages={recordings?.meta?.pages}
                    setPage={setPage}
                  />
                )}
            </Card>
          )
      }
    </>
  );
}

RecordingsList.defaultProps = {
  recordingsProcessing: 0,
};

RecordingsList.propTypes = {
  recordings: PropTypes.shape({
    data: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      length: PropTypes.number,
      visibility: PropTypes.string,
      formats: PropTypes.arrayOf(PropTypes.string),
      users: PropTypes.arrayOf(PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      })),
    })),
    meta: PropTypes.shape({
      page: PropTypes.number,
      pages: PropTypes.number,
    }),
  }).isRequired,
  isLoading: PropTypes.bool.isRequired,
  setPage: PropTypes.func.isRequired,
  searchInput: PropTypes.string.isRequired,
  setSearchInput: PropTypes.func.isRequired,
  recordingsProcessing: PropTypes.number,
};
