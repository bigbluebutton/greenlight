import React from 'react';
import PropTypes from 'prop-types';
import { Table, Container } from 'react-bootstrap';
import { Pagination } from 'semantic-ui-react';
import ProcessingRecordingRow from './ProcessingRecordingRow';
import SortBy from '../shared/SortBy';
import Spinner from '../shared/stylings/Spinner';

export default function RecordingsList({
  recordings, recordingsMeta, setPage, RecordingRow, recordingsProcessing, isLoading,
}) {
  const handlePage = (e, { activePage }) => {
    const gotopage = { activePage };
    const pagenum = gotopage.activePage;
    setPage(pagenum);
  };

  return (
    <>
      <Table hover className="table-bordered border-1 text-secondary mb-0 recordings-list">
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">Name <SortBy fieldName="name" /></th>
            <th className="fw-normal border-0">Length <SortBy fieldName="length" /></th>
            <th className="fw-normal border-0">Users</th>
            <th className="fw-normal border-0">Visibility <SortBy fieldName="visibility" /></th>
            <th className="fw-normal border-0">Formats</th>
            <th className="border-start-0" aria-label="options" />
          </tr>
        </thead>
        <tbody className="border-top-0">
          {[...Array(recordingsProcessing)].map(() => <ProcessingRecordingRow />)}
          {(isLoading && <tr><td colSpan="6"><Spinner /></td></tr>) || (recordings?.length
            ? (
              recordings?.map((recording) => <RecordingRow key={recording.id} recording={recording} />)
            )
            : (
              <tr>
                <td className="fw-bold" colSpan="6">
                  No recordings found!
                </td>
              </tr>
            ))}
        </tbody>
      </Table>
      <Container className="text-center">
        <Pagination
          defaultActivePage={recordingsMeta.page}
          totalPages={recordingsMeta.pages}
          onPageChange={handlePage}
          firstItem={null}
          lastItem={null}
          pointing
          secondary
        />
      </Container>
    </>
  );
}

RecordingsList.defaultProps = {
  recordings: [],
  recordingsProcessing: 0,
  isLoading: false,
};

RecordingsList.propTypes = {
  recordings: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    users: PropTypes.number.isRequired,
    visibility: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    map: PropTypes.func,
  })),
  recordingsMeta: PropTypes.arrayOf(PropTypes.shape({
    page: PropTypes.number.isRequired,
    pages: PropTypes.number.isRequired,
  })).isRequired,
  recordingsProcessing: PropTypes.number,
  isLoading: PropTypes.bool,
  RecordingRow: PropTypes.func.isRequired,
  setPage: PropTypes.func.isRequired,
};
