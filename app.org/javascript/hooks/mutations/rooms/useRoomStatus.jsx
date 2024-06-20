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

import { toast } from 'react-toastify';
import { useMutation } from 'react-query';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useRoomStatus(friendlyId, joinInterval) {
  const { t } = useTranslation();

  return useMutation(
    (data) => axios.post(`/meetings/${friendlyId}/status.json`, data).then((resp) => resp.data.data),
    {
      onSuccess: ({ joinUrl }) => {
        if (joinUrl) {
          clearInterval(joinInterval);
          toast.loading(t('toast.success.room.joining_meeting'));
          window.location.replace(joinUrl);
        }
      },
      onError: () => {
        clearInterval(joinInterval);
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
