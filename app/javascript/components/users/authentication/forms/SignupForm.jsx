import React, { useState, useRef } from 'react';
import { Button, Container, Stack } from 'react-bootstrap';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateUser from '../../../../hooks/mutations/users/useCreateUser';
import useEnv from '../../../../hooks/queries/env/useEnv';
import useSignUpForm from '../../../../hooks/forms/authentication/useSignUpForm';

export default function SignupForm() {
  const { t } = useTranslation();
  const { fields, methods } = useSignUpForm();
  const [token, setToken] = useState('');
  const { onSubmit: createUser } = useCreateUser(token);
  const { isSubmitting } = methods.formState;
  const { data: env } = useEnv();
  const captchaRef = useRef(null);

  const onError = () => {
    toast.error(t('toast.error.problem_completing_action'));
  };

  const onExpire = () => {
    toast.error(t('toast.error.problem_completing_action'));
  };

  return (
    <Form
      methods={methods}
      onSubmit={async (data) => {
        const response = await captchaRef.current?.execute({ async: true });
        await createUser(data, response);
      }}
    >
      <FormControl field={fields.name} type="text" autoFocus />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      { env?.HCAPTCHA_KEY
        && (
        <Container className="d-flex justify-content-center mt-3">
          <HCaptcha
            sitekey={env?.HCAPTCHA_KEY}
            size="invisible"
            onVerify={(response) => setToken(response)}
            onError={onError}
            onExpire={onExpire}
            ref={captchaRef}
          />
        </Container>
        )}
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          { isSubmitting && <Spinner className="me-2" /> }
          { t('authentication.create_account') }
        </Button>
      </Stack>
    </Form>
  );
}
