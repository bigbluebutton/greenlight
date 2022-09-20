import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import { resetPwdFormConfig, resetPwdFormFields } from '../../../../helpers/forms/ResetPwdFormHelpers';
import Spinner from '../../../shared_components/utilities/Spinner';
import useResetPwd from '../../../../hooks/mutations/users/useResetPwd';

export default function ResetPwdForm({ token }) {
  const { t } = useTranslation();
  const resetPwd = useResetPwd();
  resetPwdFormConfig.defaultValues.token = token;
  const methods = useForm(resetPwdFormConfig);
  const fields = resetPwdFormFields;

  return (
    <Form methods={methods} onSubmit={resetPwd.mutate}>
      <FormControl field={fields.new_password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={resetPwd.isLoading}>
          { t('user.account.change_password') }
          {resetPwd.isLoading && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}

ResetPwdForm.defaultProps = {
  token: '',
};

ResetPwdForm.propTypes = {
  token: PropTypes.string,
};
