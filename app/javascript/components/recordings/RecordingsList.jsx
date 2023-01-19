import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import SortBy from '../shared_components/search/SortBy';
import RecordingsListRowPlaceHolder from './RecordingsListRowPlaceHolder';

export default function RecordingsList({
  recordings, RecordingRow, recordingsProcessing, isLoading,
}) {
  const { t } = useTranslation();

  return (
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
          isLoading
            ? (
              // eslint-disable-next-line react/no-array-index-key
              [...Array(7)].map((val, idx) => <RecordingsListRowPlaceHolder key={idx} />)
            )
            : (
              (recordings?.length
                ? (
                  recordings?.map((recording) => <RecordingRow key={recording.id} recording={recording} />)
                )
                : (recordingsProcessing === 0
                  && (
                    <tr className="no-recordings-found">
                      <td className="fw-bold" colSpan="6">
                        {t('recording.no_recording_found')}
                      </td>
                    </tr>
                  )
                ))
            )
        }
      </tbody>
    </Table>
  );
}

RecordingsList.defaultProps = {
  recordings: [],
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
  })),
  recordingsProcessing: PropTypes.number,
  isLoading: PropTypes.bool,
  RecordingRow: PropTypes.func.isRequired,
};
