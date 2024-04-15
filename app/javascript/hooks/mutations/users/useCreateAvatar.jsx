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

export default function useCreateAvatar(currentUser) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  async function createAvatar(avatar) {
    // TODO - samuel: how to validate if toBlob() will transform any file into a png by default
    const avatarBlob = await new Promise((resolve) => {
      avatar.toBlob(resolve);
    });
    const formData = new FormData();
    formData.append('user[avatar]', avatarBlob);
    return axios.patch(`/users/${currentUser.id}.json`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  }

  const mutation = useMutation(
    createAvatar,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('useSessions');
        queryClient.invalidateQueries('getUser');
        toast.success(t('toast.success.user.avatar_updated'));
      },
      onError: (error) => {
        if (error.response.data.errors.includes('Avatar MalwareDetected')) {
          toast.error(t('toast.error.malware_detected'));
        } else {
          toast.error(t('toast.error.problem_completing_action'));
        }
      },
    },
  );

  const onSubmit = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  return { onSubmit, ...mutation };
}
