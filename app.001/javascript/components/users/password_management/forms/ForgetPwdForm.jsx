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

import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateResetPwd from '../../../../hooks/mutations/users/useCreateResetPwd';
import useForgetPwdForm from '../../../../hooks/forms/users/password_management/useForgetPwdForm';

export default function ForgetPwdForm() {
  const { t } = useTranslation();
  const createResetPwdAPI = useCreateResetPwd();
  const { methods, fields } = useForgetPwdForm();

  return (
    <Form methods={methods} onSubmit={createResetPwdAPI.mutate}>
      <FormControl field={fields.email} type="email" autoFocus />
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={createResetPwdAPI.isLoading}>
          {createResetPwdAPI.isLoading && <Spinner className="me-2" />}
          { t('user.account.reset_password') }
        </Button>
      </Stack>
    </Form>
  );
}
