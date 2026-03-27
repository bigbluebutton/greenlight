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
import axios from '../../../../helpers/Axios';
import { handleError } from '../../../../helpers/FileValidationHelper';
import { applyRoomDefaults, buildCreatePayload } from '../../rooms/useCreateRoom';

export default function useCreateServerRoom({ userId, onSettled }) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation(
    (room) => {
      const { data, config } = buildCreatePayload(room, userId);
      return axios.post('/rooms.json', data, config);
    },
    {
      onSuccess: async (response, room) => {
        const createdPath = response?.data?.data;

        if (createdPath) {
          const segments = createdPath.split('/').filter(Boolean);
          const friendlyId = segments[segments.length - 1];

          if (friendlyId) {
            await applyRoomDefaults(friendlyId, room);
          }
        }

        queryClient.invalidateQueries('getServerRooms');
        queryClient.invalidateQueries(['getRooms']);
        queryClient.invalidateQueries(['getUserPresentationLibrary']);
        queryClient.invalidateQueries(['getRoomPresentationLibrary']);
        toast.success(t('toast.success.room.room_created'));
      },
      onError: (err) => {
        if (err?.response?.data?.errors === 'RoomLimitError') {
          toast.error(t('toast.error.rooms.room_limit'));
        } else {
          handleError(err, t, toast);
        }
      },
      onSettled,
    },
  );
}
