import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import FormControl from './FormControl';
import Form from './Form';
import { resetPwdFormConfig, resetPwdFormFields } from '../../helpers/forms/ResetPwdFormHelpers';
import Spinner from '../shared/stylings/Spinner';
import useResetPwd from '../../hooks/mutations/users/useResetPwd';

export default function ResetPwdForm({ token }) {
  const { onSubmit: resetPwd } = useResetPwd();

  resetPwdFormConfig.defaultValues.token = token;
  const methods = useForm(resetPwdFormConfig);
  const { isSubmitting } = methods.formState;
  const fields = resetPwdFormFields;

  return (
    <Form methods={methods} onSubmit={resetPwd}>
      <FormControl field={fields.new_password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" gap={1}>
        <Button variant="primary" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          Change Password
          {isSubmitting && <Spinner />}
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
