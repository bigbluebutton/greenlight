import React from 'react';
import PropTypes from 'prop-types';
import { Card, Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import SortBy from '../shared_components/search/SortBy';
import RecordingsListRowPlaceHolder from './RecordingsListRowPlaceHolder';
import NoRecordingsFound from './NoRecordingsFound';
import RoomsRecordingRow from './room_recordings/RoomsRecordingRow';
import Pagination from '../shared_components/Pagination';

export default function RecordingsList({
  recordings, recordingsProcessing, isLoading, searchInput, setPage,
}) {
  const { t } = useTranslation();

  return (
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
  );
}

RecordingsList.defaultProps = {
  recordingsProcessing: 0,
  isLoading: false,
};

RecordingsList.propTypes = {
  recordings: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    participants: PropTypes.number.isRequired,
    visibility: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    map: PropTypes.func,
  })).isRequired,
  recordingsProcessing: PropTypes.number,
  isLoading: PropTypes.bool,
  searchInput: PropTypes.string.isRequired,
};
