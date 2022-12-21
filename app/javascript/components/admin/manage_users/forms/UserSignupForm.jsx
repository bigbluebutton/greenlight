import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useAdminCreateUser from '../../../../hooks/mutations/admin/manage_users/useAdminCreateUser';
import useCreateUserForm from '../../../../hooks/forms/admin/create_user/useCreateUserForm';

export default function UserSignupForm({ handleClose }) {
  const { t } = useTranslation();
  const { fields, methods } = useCreateUserForm();
  const createUserAPI = useAdminCreateUser({ onSettled: handleClose });

  return (
    <Form methods={methods} onSubmit={createUserAPI.mutate}>
      <FormControl field={fields.name} type="text" autoFocus />
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <FormControl field={fields.password_confirmation} type="password" />

      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          {t('close')}
        </Button>
        <Button variant="brand" type="submit" disabled={createUserAPI.isLoading}>
          { createUserAPI.isLoading && <Spinner className="me-2" /> }
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
