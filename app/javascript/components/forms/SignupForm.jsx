import React, { useState, useRef } from 'react';
import { Button, Container, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import FormControl from './FormControl';
import Form from './Form';
import { signupFormConfig, signupFormFields } from '../../helpers/forms/SignupFormHelpers';
import Spinner from '../shared/stylings/Spinner';
import useCreateUser from '../../hooks/mutations/users/useCreateUser';
import useEnv from '../../hooks/queries/env/useEnv';

export default function SignupForm() {
  const methods = useForm(signupFormConfig);
  const [token, setToken] = useState('');
  const { onSubmit: createUser } = useCreateUser(token);
  const { isSubmitting } = methods.formState;
  const fields = signupFormFields;
  const { isLoading, data: env } = useEnv();
  const captchaRef = useRef(null);

  if (isLoading) return <Spinner />;

  const onError = (err) => {
    console.log(`hCaptcha Error: ${err}`);
  };

  const onExpire = () => {
    console.log('hCaptcha Token Expired');
  };

  return (
    <Form
      methods={methods}
      onSubmit={async (data) => {
        const response = await captchaRef.current?.execute({ async: true });
        await createUser(data, response);
      }}
    >
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      { env.HCAPTCHA_KEY
        && (
        <Container className="d-flex justify-content-center mt-3">
          <HCaptcha
            sitekey={env.HCAPTCHA_KEY}
            size="invisible"
            onVerify={(response) => setToken(response)}
            onError={onError}
            onExpire={onExpire}
            ref={captchaRef}
          />
        </Container>
        )}
      <Stack className="mt-1" gap={1}>
        <Button variant="primary" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          Create account
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}
