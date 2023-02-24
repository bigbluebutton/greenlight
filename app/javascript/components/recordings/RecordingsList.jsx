// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import PropTypes from 'prop-types';
import { Card, Stack, Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import SortBy from '../shared_components/search/SortBy';
import RecordingsListRowPlaceHolder from './RecordingsListRowPlaceHolder';
import NoSearchResults from '../shared_components/search/NoSearchResults';
import RoomsRecordingRow from './room_recordings/RoomsRecordingRow';
import Pagination from '../shared_components/Pagination';
import EmptyRecordingsList from './EmptyRecordingsList';
import SearchBar from '../shared_components/search/SearchBar';
import ProcessingRecordingRow from './ProcessingRecordingRow';

export default function RecordingsList({
  recordings, isLoading, setPage, searchInput, setSearchInput, recordingsProcessing, adminTable,
}) {
  const { t } = useTranslation();

  if (!isLoading && recordings?.data?.length === 0 && !searchInput && recordingsProcessing === 0) {
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
              <NoSearchResults text={t('recording.search_not_found')} searchInput={searchInput} />
            </div>
          ) : (
            <Card className="border-0 card-shadow p-0 mt-4 mb-5">
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
                  {[...Array(recordingsProcessing)].map(() => <ProcessingRecordingRow />)}
                  {
                    (isLoading && [...Array(7)].map((val, idx) => (
                      // eslint-disable-next-line react/no-array-index-key
                      <RecordingsListRowPlaceHolder key={idx} />
                    )))
                  }
                  {
                    (recordings?.data?.length > 0 && recordings?.data?.map((recording) => (
                      <RoomsRecordingRow key={recording.id} recording={recording} adminTable={adminTable} />
                    )))
                  }
                </tbody>
                { (recordings?.meta?.pages > 1)
                  && (
                    <tfoot>
                      <tr>
                        <td colSpan={12}>
                          <Pagination
                            page={recordings?.meta?.page}
                            totalPages={recordings?.meta?.pages}
                            setPage={setPage}
                          />
                        </td>
                      </tr>
                    </tfoot>
                  )}
              </Table>
            </Card>
          )
      }
    </>
  );
}

RecordingsList.defaultProps = {
  recordings: { data: [], meta: { page: 1, pages: 1 } },
  recordingsProcessing: 0,
  searchInput: '',
  adminTable: false,
};

RecordingsList.propTypes = {
  recordings: PropTypes.shape({
    data: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.string,
      name: PropTypes.string,
      length: PropTypes.number,
      visibility: PropTypes.string,
      formats: PropTypes.arrayOf(PropTypes.shape({
        recording_type: PropTypes.string,
        url: PropTypes.string,
      })),
      users: PropTypes.arrayOf(PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      })),
    })),
    meta: PropTypes.shape({
      page: PropTypes.number,
      pages: PropTypes.number,
    }),
  }),
  isLoading: PropTypes.bool.isRequired,
  setPage: PropTypes.func.isRequired,
  searchInput: PropTypes.string,
  setSearchInput: PropTypes.func.isRequired,
  recordingsProcessing: PropTypes.number,
  adminTable: PropTypes.bool,
};
