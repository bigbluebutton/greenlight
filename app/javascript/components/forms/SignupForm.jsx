import React, { useState } from 'react';
import { Button, Container, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import FormControl from './FormControl';
import Form from './Form';
import { signupFormConfig, signupFormFields } from '../../helpers/forms/SignupFormHelpers';
import Spinner from '../shared/stylings/Spinner';
import useCreateUser from '../../hooks/mutations/users/useCreateUser';

export default function SignupForm() {
  const methods = useForm(signupFormConfig);
  const [token, setToken] = useState('');
  const { onSubmit } = useCreateUser(token);
  const { isSubmitting } = methods.formState;
  const fields = signupFormFields;

  const onError = (err) => {
    console.log(`hCaptcha Error: ${err}`);
  };

  const onExpire = () => {
    console.log('hCaptcha Token Expired');
  };

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      <Container className="d-flex justify-content-center mt-3">
        {/* TODO: - Make sitekey dynamic (Maybe ENV variable) */}
        <HCaptcha
          sitekey="deafadd9-444a-4025-bb80-86e83cd3aed2"
          onVerify={(response) => setToken(response)}
          onError={onError}
          onExpire={onExpire}
        />
      </Container>
      <Stack className="mt-1" gap={1}>
        <Button variant="primary" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          Create account
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}
