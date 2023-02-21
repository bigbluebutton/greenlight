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

import { t } from 'i18next';
import { toast } from 'react-toastify';
import { useMutation, useQueryClient } from 'react-query';

import axios from '../../../../helpers/Axios';

export default function useRecordingsReSync(friendlyId) {
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.get(`/admin/server_rooms/${friendlyId}/resync.json`),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getServerRecordings');
        queryClient.invalidateQueries(['getRoomRecordings', { friendlyId }]);
        queryClient.invalidateQueries(['getRecordings']);
        toast.success(t('toast.success.room.recordings_synced'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
