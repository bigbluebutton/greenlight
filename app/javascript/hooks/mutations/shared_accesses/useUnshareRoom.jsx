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

import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';

// Similar to useDeleteSharedAccess, but this one is specifically for unsharing a room that is shared with a user as the user
export default function useUnshareRoom(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation(
    (data) => axios.post(`/shared_accesses/${friendlyId}/unshare_room.json`, { data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSharedUsers');
        queryClient.invalidateQueries(['getRoom', { friendlyId }]);
        navigate('/rooms');
        toast.success(t('toast.success.room.room_unshared'));
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
