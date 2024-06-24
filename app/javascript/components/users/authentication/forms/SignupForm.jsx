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

import React, { useRef, useCallback } from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateUser from '../../../../hooks/mutations/users/useCreateUser';
import useSignUpForm from '../../../../hooks/forms/users/authentication/useSignUpForm';
import HCaptcha from '../../../shared_components/utilities/HCaptcha';

export default function SignupForm({registrationMethod}) {
  const { t } = useTranslation();
  const { fields, methods } = useSignUpForm(registrationMethod);
  const createUserAPI = useCreateUser();
  const captchaRef = useRef(null);

  const handleSubmit = useCallback(async (user) => {
    const results = await captchaRef.current?.execute({ async: true });
    const token = results?.response || '';

    return createUserAPI.mutate({ user, token });
  }, [captchaRef.current, createUserAPI.mutate]);

  return (
    <Form methods={methods} onSubmit={handleSubmit}>
      <FormControl field={fields.name} type="text" autoFocus />
      { registrationMethod !== 'invite' && (
      <FormControl field={fields.email} type="email" />
      )}
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      <HCaptcha ref={captchaRef} />
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 my-3 mt-1" type="submit" disabled={createUserAPI.isLoading}>
          { createUserAPI.isLoading && <Spinner className="me-2" /> }
          { t('authentication.create_account') }
        </Button>
      </Stack>
    </Form>
  );
}
