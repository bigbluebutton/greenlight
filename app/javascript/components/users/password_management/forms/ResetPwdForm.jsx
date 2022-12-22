import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useResetPwd from '../../../../hooks/mutations/users/useResetPwd';
import useResetPwdForm from '../../../../hooks/forms/users/password_management/useResetPwdForm';

export default function ResetPwdForm({ token }) {
  const { t } = useTranslation();
  const resetPwdAPI = useResetPwd();
  const { methods, fields } = useResetPwdForm({ defaultValues: { token } });

  return (
    <Form methods={methods} onSubmit={resetPwdAPI.mutate}>
      <FormControl field={fields.new_password} type="password" autoFocus />
      <FormControl field={fields.password_confirmation} type="password" />
      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={resetPwdAPI.isLoading}>
          {resetPwdAPI.isLoading && <Spinner className="me-2" />}
          { t('user.account.change_password') }
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
