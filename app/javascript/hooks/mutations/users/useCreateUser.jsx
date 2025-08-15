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

export default function useCreateUser() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [searchParams] = useSearchParams();
  const redirect = searchParams.get('location');
  const inviteToken = searchParams.get('inviteToken') || '';

  return useMutation(
    ({ user, token }) => axios.post('/users.json', { user: { language: i18n.resolvedLanguage, invite_token: inviteToken, ...user }, token })
      .then((resp) => resp.data.data),
    {
      onSuccess: async (response) => {
        await queryClient.refetchQueries('useSessions');

        // if the current user does NOT have the CreateRoom permission, then do not re-direct to rooms page
        if (!response.verified) {
          navigate(`/verify?id=${response.id}`);
        } else if (redirect) {
          navigate(redirect);
        } else if (response.permissions.CreateRoom === 'false') {
          navigate('/home');
        } else {
          navigate('/rooms');
        }
      },
      onError: (err) => {
        if (err.response.data.errors === 'InviteInvalid') {
          toast.error(t('toast.error.users.invalid_invite'));
        } else if (err.response.data.errors === 'EmailAlreadyExists') {
          toast.error(t('toast.error.users.email_exists'));
        } else if (err.response.data.errors === 'BannedUser') {
          toast.error(t('toast.error.users.banned'));
        } else if (err.response.data.errors === 'HCaptchaInvalid') {
          toast.error(t('toast.error.users.hcaptcha_invalid'));
        } else {
          toast.error(t('toast.error.problem_completing_action'));
        }
      },
    },
  );
}
