import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import FormControl from '../../../forms/FormControl';
import Form from '../../../forms/Form';
import { changePwdFormConfig, changePwdFormFields } from '../../../../helpers/forms/ChangePwdFormHelpers';
import Spinner from '../../../shared_components/stylings/Spinner';
import useChangePwd from '../../../../hooks/mutations/users/useChangePwd';

export default function ChangePwdForm() {
  const methods = useForm(changePwdFormConfig);
  const fields = changePwdFormFields;
  const changePwd = useChangePwd();

  return (
    <Form
      methods={methods}
      onSubmit={changePwd.mutate}
    >
      <FormControl field={fields.old_password} type="password" />
      <FormControl field={fields.new_password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={changePwd.isLoading}>
          Change password
          {changePwd.isLoading && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}
