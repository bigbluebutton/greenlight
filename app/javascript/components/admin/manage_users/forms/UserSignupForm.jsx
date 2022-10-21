import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import { signupFormConfig, signupFormFields } from '../../../../helpers/forms/SignupFormHelpers';
import Spinner from '../../../shared_components/utilities/Spinner';
import useAdminCreateUser from '../../../../hooks/mutations/admin/manage_users/useAdminCreateUser';

export default function UserSignupForm({ handleClose }) {
  const { t } = useTranslation();
  const methods = useForm(signupFormConfig);
  const createUser = useAdminCreateUser({ onSettled: handleClose });
  const { isSubmitting } = methods.formState;
  const fields = signupFormFields;

  fields.name.placeHolder = t('admin.manage_users.enter_user_name');
  fields.email.placeHolder = t('admin.manage_users.enter_user_email');

  return (
    <Form methods={methods} onSubmit={createUser.mutate}>
      <FormControl field={fields.name} type="text" />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" gap={1}>
        <Button variant="brand" className="w-100 mb- mt-1" type="submit" disabled={isSubmitting}>
          { t('admin.manage_users.create_account') }
          { isSubmitting && <Spinner /> }
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
