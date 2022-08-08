import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import FormControl from '../../forms/FormControl';
import Form from '../../forms/Form';
import { signupFormConfig, signupFormFields } from '../../../helpers/forms/SignupFormHelpers';
import Spinner from '../../shared_components/utilities/Spinner';
import useAdminCreateUser from '../../../hooks/mutations/admin/manage_users/useAdminCreateUser';

export default function AdminSignupForm({ handleClose }) {
  const methods = useForm(signupFormConfig);
  const createUser = useAdminCreateUser({ onSettled: handleClose });
  const { isSubmitting } = methods.formState;
  const fields = signupFormFields;

  return (
    <Form methods={methods} onSubmit={createUser.mutate}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          Create account
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}

AdminSignupForm.propTypes = {
  handleClose: PropTypes.func,
};

AdminSignupForm.defaultProps = {
  handleClose: () => { },
};
