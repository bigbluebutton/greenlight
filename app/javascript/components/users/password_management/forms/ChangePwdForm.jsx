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
import useChangePwd from '../../../../hooks/mutations/users/useChangePwd';
import useChangePwdForm from '../../../../hooks/forms/users/password_management/useChangePwdForm';

export default function ChangePwdForm() {
  const { t } = useTranslation();
  const { methods, fields, reset } = useChangePwdForm();
  const changePwdAPI = useChangePwd();

  return (
    <Form methods={methods} onSubmit={changePwdAPI.mutate}>
      <FormControl field={fields.old_password} type="password" autoFocus />
      <FormControl field={fields.new_password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      <Stack direction="horizontal" gap={2} className="float-end">
        <Button variant="neutral" onClick={reset}> { t('cancel') } </Button>
        <Button variant="brand" type="submit" disabled={changePwdAPI.isLoading}>
          {changePwdAPI.isLoading && <Spinner className="me-2" />}
          { t('user.account.change_password') }
        </Button>
      </Stack>
    </Form>
  );
}
