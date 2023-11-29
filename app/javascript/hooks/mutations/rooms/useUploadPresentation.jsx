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
import { fileValidation, handleError } from '../../../helpers/FileValidationHelper';

export default function useUploadPresentation(friendlyId) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const uploadPresentation = (presentation) => {
    fileValidation(presentation, 'presentation');
    const formData = new FormData();
    formData.append('room[presentation]', presentation);
    return axios.patch(`/rooms/${friendlyId}.json`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  };

  const mutation = useMutation(uploadPresentation, {
    onSuccess: () => {
      queryClient.invalidateQueries(['getRoom', { friendlyId }]);
      toast.success(t('toast.success.room.presentation_updated'));
    },
    onError: (error) => {
      handleError(error, t, toast);
    },
  });

  const onSubmit = async (data) => {
    await mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { onSubmit, ...mutation };
}
