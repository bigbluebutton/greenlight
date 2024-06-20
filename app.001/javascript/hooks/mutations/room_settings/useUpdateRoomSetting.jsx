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
import axios from '../../../helpers/Axios';

export default function useUpdateRoomSetting(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  // If guestPolicy setting is toggled, bool are rewritten to string values as per BBB API.
  const updateRoomSetting = (_data) => {
    const data = { ..._data };
    if (data.settingName === 'guestPolicy') {
      data.settingValue = data.settingValue ? 'ASK_MODERATOR' : 'ALWAYS_ACCEPT';
    }
    return axios.patch(`/room_settings/${friendlyId}.json`, data);
  };

  // Returns a more suiting toast message if the updated room setting is an access code
  const toastSuccess = (variables) => {
    if (variables.settingName === 'glModeratorAccessCode' || variables.settingName === 'glViewerAccessCode') {
      if (variables.settingValue) {
        return toast.success(t('toast.success.room.access_code_generated'));
      }
      return toast.success(t('toast.success.room.access_code_deleted'));
    }
    return toast.success(t('toast.success.room.room_setting_updated'));
  };

  return useMutation(
    updateRoomSetting,
    {
      onSuccess: (data, variables) => {
        queryClient.invalidateQueries('getRoomSettings');
        toastSuccess(variables);
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
