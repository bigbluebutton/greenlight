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

import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { VideoCameraIcon } from '@heroicons/react/24/outline';
import { Card, Stack, Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import SortBy from '../../../shared_components/search/SortBy';
import NoSearchResults from '../../../shared_components/search/NoSearchResults';
import Pagination from '../../../shared_components/Pagination';
import SearchBar from '../../../shared_components/search/SearchBar';
import usePublicRecordings from '../../../../hooks/queries/recordings/usePublicRecordings';
import PublicRecordingRow from './PublicRecordingRow';
import PublicRecordingsRowPlaceHolder from './PublicRecordingsRowPlaceHolder';
import ButtonLink from '../../../shared_components/utilities/ButtonLink';
import UserBoardIcon from '../../UserBoardIcon';

export default function PublicRecordingsList({ friendlyId }) {
  const { t } = useTranslation();
  const [page, setPage] = useState(1);
  const [searchInput, setSearchInput] = useState('');
  const { data: recordings, ...publicRecordingsAPI } = usePublicRecordings({ friendlyId, page, search: searchInput });

  if (!publicRecordingsAPI.isLoading && recordings?.data?.length === 0 && !searchInput) {
    return (
      <div className="text-center my-4">
        <div className="icon-circle rounded-circle d-block mx-auto mb-3">
          <VideoCameraIcon className="hi-l pt-4 text-brand d-block mx-auto" />
        </div>
        <h2 className="text-brand"> {t('recording.public_recordings_list_empty')}</h2>
        <p>
          {t('recording.public_recordings_list_empty_description')}
        </p>
        <ButtonLink
          variant="brand"
          className="ms-auto my-0 py-2"
          to={`/rooms/${friendlyId}/join`}
        >
          <span> <UserBoardIcon className="hi-s cursor-pointer" /> {t('join_session')} </span>
        </ButtonLink>
      </div>
    );
  }

  return (
    <>
      <Stack direction="horizontal" className="w-100">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
        </div>
        <ButtonLink
          variant="brand-outline"
          className="ms-auto my-0 py-2"
          to={`/rooms/${friendlyId}/join`}
        >
          <span> <UserBoardIcon className="hi-s text-brand cursor-pointer" /> {t('join_session')} </span>
        </ButtonLink>
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
                    <th className="fw-normal border-0">{t('recording.formats')}</th>
                  </tr>
                </thead>
                <tbody className="border-top-0">
                  {
                    (publicRecordingsAPI.isLoading && [...Array(7)].map((val, idx) => (
                      // eslint-disable-next-line react/no-array-index-key
                      <PublicRecordingsRowPlaceHolder key={idx} />
                    )))
                  }
                  {
                    (recordings?.data?.length > 0 && recordings?.data?.map((recording) => (
                      <PublicRecordingRow key={recording.id} recording={recording} />
                    )))
                  }
                </tbody>
                {(recordings?.meta?.pages > 1)
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

PublicRecordingsList.propTypes = {
  friendlyId: PropTypes.string.isRequired,
};
