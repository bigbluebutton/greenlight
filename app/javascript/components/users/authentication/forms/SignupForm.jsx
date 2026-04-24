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

import React, { useRef, useCallback, useEffect } from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateUser from '../../../../hooks/mutations/users/useCreateUser';
import useSignUpForm from '../../../../hooks/forms/users/authentication/useSignUpForm';
import HCaptcha from '../../../shared_components/utilities/HCaptcha';

export default function SignupForm({ invitation }) {
  const { t } = useTranslation();
  const { fields, methods } = useSignUpForm();
  const createUserAPI = useCreateUser();
  const captchaRef = useRef(null);

  useEffect(() => {
    if (invitation?.email) {
      methods.setValue('email', invitation.email, { shouldValidate: true });
    }
    if (invitation?.name) {
      methods.setValue('name', invitation.name, { shouldValidate: true });
    }
  }, [invitation]);

  const handleSubmit = useCallback(async (user) => {
    const results = await captchaRef.current?.execute({ async: true });
    const token = results?.response || '';

    // Re-add invitation values that may be excluded by disabled fields
    const userData = { ...user };
    if (invitation?.name) { userData.name = invitation.name; }
    if (invitation?.email) { userData.email = invitation.email; }

    return createUserAPI.mutate({ user: userData, token });
  }, [captchaRef.current, createUserAPI.mutate, invitation]);

  return (
    <Form methods={methods} onSubmit={handleSubmit}>
      <FormControl field={fields.name} type="text" autoFocus disabled={!!invitation?.name} />
      <FormControl field={fields.email} type="email" disabled={!!invitation?.email} />
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

SignupForm.propTypes = {
  invitation: PropTypes.shape({
    email: PropTypes.string,
    name: PropTypes.string,
  }),
};

SignupForm.defaultProps = {
  invitation: undefined,
};
