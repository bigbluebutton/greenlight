import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import { ExclamationTriangleIcon } from '@heroicons/react/24/outline';
import Form
  from '../../../shared_components/forms/Form';
import useDeleteUser from '../../../../hooks/mutations/admin/manage_users/useDeleteUser';
import Spinner from '../../../shared_components/utilities/Spinner';

export default function DeleteUserForm({ user, handleClose }) {
  const { t } = useTranslation();
  const methods = useForm();
  const deleteUserAPI = useDeleteUser(user.id);

  return (
    <>
      <Stack direction="horizontal" className="mb-3">
        <ExclamationTriangleIcon className="text-danger hi-xl" />
        <Stack direction="vertical" className="ps-3">
          <h3> {t('admin.manage_users.delete_user')} </h3>
          <p className="mb-0">{ t('admin.manage_users.are_you_sure_delete_account', { user }) }</p>
          <p className="mt-0"><strong> { t('action_permanent') } </strong></p>
        </Stack>
      </Stack>
      <Form methods={methods} onSubmit={deleteUserAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="neutral" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="danger" type="submit" disabled={deleteUserAPI.isLoading}>
            { deleteUserAPI.isLoading && <Spinner className="me-2" /> }
            { t('delete') }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteUserForm.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
  handleClose: PropTypes.func,
};

DeleteUserForm.defaultProps = {
  handleClose: () => {},
};
