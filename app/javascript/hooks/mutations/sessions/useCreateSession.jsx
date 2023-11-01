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
import { useNavigate, useSearchParams } from 'react-router-dom';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useCreateSession() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('location');

  return useMutation(
    ({ session, token }) => axios.post('/sessions.json', { session, token }).then((resp) => resp.data.data),
    {
      onSuccess: async (response) => {
        await queryClient.refetchQueries('useSessions');
        // if the current user does NOT have the CreateRoom permission, then do not re-direct to rooms page

        if (redirect) {
          navigate(redirect);
        } else if (response.permissions.CreateRoom === 'false') {
          navigate('/home');
        } else {
          navigate('/rooms');
        }
      },
      onError: (err) => {
        if (err.response.data.errors === 'PendingUser') {
          navigate('/pending');
        } else if (err.response.data.errors === 'BannedUser') {
          toast.error(t('toast.error.users.banned'));
        } else if (err.response.data.errors === 'UnverifiedUser') {
          navigate(`/verify?id=${err.response.data.data}`);
        } else if (err.response.data.errors === 'PasswordNotSet') {
          navigate(`/reset_password/${err.response.data.data}`);
        } else {
          toast.error(t('toast.error.session.invalid_credentials'));
        }
      },
    },
  );
}
