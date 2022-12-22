import React, { useRef, useCallback } from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateUser from '../../../../hooks/mutations/users/useCreateUser';
import useSignUpForm from '../../../../hooks/forms/authentication/useSignUpForm';
import HCaptcha from '../../../shared_components/utilities/HCaptcha';

export default function SignupForm() {
  const { t } = useTranslation();
  const { fields, methods } = useSignUpForm();
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
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      <HCaptcha ref={captchaRef} />
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={createUserAPI.isLoading}>
          { createUserAPI.isLoading && <Spinner className="me-2" /> }
          { t('authentication.create_account') }
        </Button>
      </Stack>
    </Form>
  );
}
