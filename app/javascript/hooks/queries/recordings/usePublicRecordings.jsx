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

import { useQuery } from 'react-query';
import { useSearchParams } from 'react-router-dom';
import axios from '../../../helpers/Axios';

export default function usePublicRecordings({ friendlyId, search, page, accessCode }) {
  const [searchParams] = useSearchParams();
  const params = {
    'sort[column]': searchParams.get('sort[column]'),
    'sort[direction]': searchParams.get('sort[direction]'),
    search,
    page,
    ...(accessCode ? { access_code: accessCode } : {}),
  };

  return useQuery(
    ['getPublicRecordings', friendlyId, { ...params }],
    () => {
      return axios.get(`/rooms/${friendlyId}/public_recordings.json`, { params })
        .then((resp) => {
          return resp.data;
        })
        .catch((error) => {
          // Only keep console.error for important errors
          console.error('usePublicRecordings: API error:', error);
          throw error;
        });
    },
    {
      keepPreviousData: true,
      retry: false, // Don't retry on 401/403 errors
      staleTime: 60000, // Data remains fresh for 1 minute
      cacheTime: 300000, // Cache data for 5 minutes
      refetchOnWindowFocus: false, // Don't refetch when window regains focus
      // Only refetch if access code changes to avoid unnecessary requests
      refetchOnMount: accessCode ? true : 'stale',
    },
  );
}
