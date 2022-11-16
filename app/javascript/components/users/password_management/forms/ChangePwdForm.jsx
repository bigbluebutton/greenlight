import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import { changePwdFormConfig, changePwdFormFields } from '../../../../helpers/forms/ChangePwdFormHelpers';
import Spinner from '../../../shared_components/utilities/Spinner';
import useChangePwd from '../../../../hooks/mutations/users/useChangePwd';

export default function ChangePwdForm() {
  const { t } = useTranslation();
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

      <Stack direction="horizontal" gap={2} className="float-end">
        <Button
          variant="neutral"
          onClick={() => methods.reset({
            old_password: '',
            new_password: '',
          })}
        >
          { t('cancel') }
        </Button>
        <Button variant="brand" type="submit" disabled={changePwd.isLoading}>
          {changePwd.isLoading && <Spinner className="me-2" />}
          { t('user.account.change_password') }
        </Button>
      </Stack>
    </Form>
  );
}
