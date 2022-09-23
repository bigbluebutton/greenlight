import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import useDeleteUser from '../../../../hooks/mutations/users/useDeleteUser';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import Spinner from '../../../shared_components/utilities/Spinner';

export default function DeleteUserForm({ handleClose }) {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const methods = useForm();
  const deleteUserAPI = useDeleteUser(currentUser?.id);

  return (
    <>
      <p className="text-center"> { t('user.account.are_you_sure_delete_account') }</p>
      <Form methods={methods} onSubmit={deleteUserAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="brand-outline" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="danger" type="submit" disabled={deleteUserAPI.isLoading}>
            { t('user.account.delete_account') }
            { deleteUserAPI.isLoading && <Spinner /> }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteUserForm.propTypes = {
  handleClose: PropTypes.func,
};

DeleteUserForm.defaultProps = {
  handleClose: () => {},
};
