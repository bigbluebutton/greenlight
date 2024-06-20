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

import { useMutation } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import axios from '../../../helpers/Axios';

export default function useCreateResetPwd() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  return useMutation(
    (user) => axios.post('/reset_password.json', { user }),
    {
      onSuccess: () => {
        toast.success(t('toast.success.user.reset_pwd_email_sent'));
        navigate('/');
      },
      onError: () => {
        toast.error(t('toast.error.problem_completing_action'));
      },
    },
  );
}
