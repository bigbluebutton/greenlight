import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useAdminCreateUser from '../../../../hooks/mutations/admin/manage_users/useAdminCreateUser';
import useSignUpForm from '../../../../hooks/forms/authentication/useSignUpForm';

export default function UserSignupForm({ handleClose }) {
  const { t } = useTranslation();
  const { fields, methods } = useSignUpForm();
  const createUser = useAdminCreateUser({ onSettled: handleClose });
  const { isSubmitting } = methods.formState;

  fields.name.placeHolder = t('admin.manage_users.enter_user_name');
  fields.email.placeHolder = t('admin.manage_users.enter_user_email');

  return (
    <Form methods={methods} onSubmit={createUser.mutate}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          {t('close')}
        </Button>
        <Button variant="brand" type="submit" disabled={isSubmitting}>
          { isSubmitting && <Spinner className="me-2" /> }
          { t('admin.manage_users.create_account') }
        </Button>
      </Stack>
    </Form>
  );
}

UserSignupForm.propTypes = {
  handleClose: PropTypes.func,
};

UserSignupForm.defaultProps = {
  handleClose: () => { },
};
