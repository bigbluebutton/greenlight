import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateResetPwd from '../../../../hooks/mutations/users/useCreateResetPwd';
import useForgetPwdForm from '../../../../hooks/forms/users/password_management/useForgetPwdForm';

export default function ForgetPwdForm() {
  const { t } = useTranslation();
  const createResetPwdAPI = useCreateResetPwd();
  const { methods, fields } = useForgetPwdForm();

  return (
    <Form methods={methods} onSubmit={createResetPwdAPI.mutate}>
      <FormControl field={fields.email} type="email" autoFocus />
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={createResetPwdAPI.isLoading}>
          {createResetPwdAPI.isLoading && <Spinner className="me-2" />}
          { t('user.account.reset_password') }
        </Button>
      </Stack>
    </Form>
  );
}
