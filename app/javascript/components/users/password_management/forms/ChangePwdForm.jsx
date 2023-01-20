import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useChangePwd from '../../../../hooks/mutations/users/useChangePwd';
import useChangePwdForm from '../../../../hooks/forms/users/password_management/useChangePwdForm';

export default function ChangePwdForm() {
  const { t } = useTranslation();
  const { methods, fields, reset } = useChangePwdForm();
  const changePwdAPI = useChangePwd();

  return (
    <Form methods={methods} onSubmit={changePwdAPI.mutate}>
      <FormControl field={fields.old_password} type="password" autoFocus />
      <FormControl field={fields.new_password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />
      <Stack direction="horizontal" gap={2} className="float-end">
        <Button variant="neutral" onClick={reset}> { t('cancel') } </Button>
        <Button variant="brand" type="submit" disabled={changePwdAPI.isLoading}>
          {changePwdAPI.isLoading && <Spinner className="me-2" />}
          { t('user.account.change_password') }
        </Button>
      </Stack>
    </Form>
  );
}
