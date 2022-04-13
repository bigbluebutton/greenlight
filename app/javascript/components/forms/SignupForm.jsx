import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import FormControl from './FormControl';
import Form from './Form';
import { signupFormConfig, signupFormFields } from '../../helpers/forms/SignupFormHelpers';
import Spinner from '../shared/stylings/Spinner';
import useCreateUser from '../../hooks/mutations/users/useCreateUser';

export default function SignupForm() {
  const methods = useForm(signupFormConfig);
  const { onSubmit } = useCreateUser();
  const { isSubmitting } = methods.formState;
  const fields = signupFormFields;
  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      <Stack className="mt-1" gap={1}>
        <Button variant="primary" className="w-100 my-3 py-2" type="submit" disabled={isSubmitting}>
          Create account
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}
