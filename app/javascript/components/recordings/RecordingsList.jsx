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
import {
  Badge, Card, Stack, Table,
} from 'react-bootstrap';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';
import { useTranslation } from 'react-i18next';
import { QuestionMarkCircleIcon } from '@heroicons/react/24/outline';
import Popover from 'react-bootstrap/Popover';
import SortBy from '../shared_components/search/SortBy';
import RecordingsListRowPlaceHolder from './RecordingsListRowPlaceHolder';
import NoSearchResults from '../shared_components/search/NoSearchResults';
import RoomsRecordingRow from './room_recordings/RoomsRecordingRow';
import Pagination from '../shared_components/Pagination';
import EmptyRecordingsList from './EmptyRecordingsList';
import SearchBar from '../shared_components/search/SearchBar';

export default function RecordingsList({
  recordings, isLoading, setPage, searchInput, setSearchInput, recordingsProcessing, adminTable, numPlaceholders,
}) {
  const { t } = useTranslation();

  const formatsTooltip = (
    <Popover>
      <Popover.Body>
        <p className="mb-0">{t('recording.formats_help')}</p>
      </Popover.Body>
    </Popover>
  );

  if (!isLoading && recordings?.data?.length === 0 && !searchInput && recordingsProcessing === 0) {
    return <EmptyRecordingsList />;
  }

  return (
    <>
      <Stack direction="horizontal" className="w-100">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
        { recordingsProcessing > 0 && (
          <Badge className="ms-auto badge-brand-outline p-2">
            <Stack direction="horizontal" gap={2}>
              <Badge className="rounded-pill recordings-count-badge ms-2 text-brand">
                { recordingsProcessing }
              </Badge>
              <span> { t('recording.processing') } </span>
            </Stack>
          </Badge>
        )}
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
                    <th className="fw-normal border-0">
                      <Stack direction="horizontal" gap={1} className="align-items-center">
                        <span>{t('recording.formats')}</span>
                        <OverlayTrigger
                          placement="top"
                          trigger={['hover', 'focus']}
                          overlay={formatsTooltip}
                        >
                          <button type="button" className="btn btn-link p-0 border-0 d-inline-flex text-muted cursor-pointer">
                            <QuestionMarkCircleIcon className="hi-xs" />
                          </button>
                        </OverlayTrigger>
                      </Stack>
                    </th>
                    <th className="border-start-0" aria-label="options" />
                  </tr>
                </thead>
                <tbody className="border-top-0">
                  {
                    isLoading && Array.from({ length: numPlaceholders }).map((_, idx) => (
                      // eslint-disable-next-line react/no-array-index-key
                      <RecordingsListRowPlaceHolder key={idx} />
                    ))
                  }
                  {
                    (recordings?.data?.length > 0 && recordings?.data?.map((recording, idx) => (
                      <RoomsRecordingRow
                        key={recording.id}
                        recording={recording}
                        adminTable={adminTable}
                        dropUp={(recordings?.meta?.page || 0) * (recordings?.meta?.items || 0) - 1 === idx}
                      />
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
  recordings: { data: [], meta: { page: 1, pages: 1, items: 3 } },
  recordingsProcessing: 0,
  searchInput: '',
  adminTable: false,
  numPlaceholders: 7,
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
      items: PropTypes.number,
    }),
  }),
  isLoading: PropTypes.bool.isRequired,
  setPage: PropTypes.func.isRequired,
  searchInput: PropTypes.string,
  setSearchInput: PropTypes.func.isRequired,
  recordingsProcessing: PropTypes.number,
  adminTable: PropTypes.bool,
  numPlaceholders: PropTypes.number,
};
