import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import FormControl from './FormControl';
import Form from './Form';
import { changePwdFormConfig, changePwdFormFields } from '../../helpers/forms/ChangePwdFormHelpers';
import Spinner from '../shared/stylings/Spinner';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useChangePwd from '../../hooks/mutations/users/useChangePwd';

export default function ChangePwdForm() {
  const currentUser = useAuth();
  const methods = useForm(changePwdFormConfig);
  const fields = changePwdFormFields;
  const { isSubmitting } = methods.formState;
  const { onSubmit: handleChangePwd } = useChangePwd(currentUser.id);

  return (
    <Form
      methods={methods}
      onSubmit={handleChangePwd}
    >
      <FormControl field={fields.old_password} type="password" />
      <FormControl field={fields.new_password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" gap={1}>
        <Button variant="primary" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          Change password
          {isSubmitting && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}
