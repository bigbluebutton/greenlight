import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import FormControl from '../../../forms/FormControl';
import Form from '../../../forms/Form';
import { forgetPwdFormConfig, forgetPwdFormFields } from '../../../../helpers/forms/ForgetPwdFormHelpers';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateResetPwd from '../../../../hooks/mutations/users/useCreateResetPwd';

export default function ForgetPwdForm() {
  const createResetPwd = useCreateResetPwd();
  const methods = useForm(forgetPwdFormConfig);
  const { isSubmitting } = methods.formState;
  const fields = forgetPwdFormFields;

  return (
    <Form methods={methods} onSubmit={createResetPwd.mutate}>
      <FormControl field={fields.email} type="email" />

      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          Reset Password
          {isSubmitting && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}
