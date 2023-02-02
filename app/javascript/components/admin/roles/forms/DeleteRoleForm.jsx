import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import { ExclamationTriangleIcon } from '@heroicons/react/24/outline';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useDeleteRole from '../../../../hooks/mutations/admin/roles/useDeleteRole';

export default function DeleteRoleForm({ role, handleClose }) {
  const { t } = useTranslation();
  const deleteRoleAPI = useDeleteRole({ role, onSettled: handleClose });
  const methods = useForm();

  return (
    <>
      <Stack direction="horizontal" className="mb-3">
        <ExclamationTriangleIcon className="text-danger hi-xl" />
        <Stack direction="vertical" className="ps-3">
          <h3> { t('admin.roles.delete_role') } </h3>
          <p className="mb-0"> { t('admin.roles.are_you_sure_delete_role') } </p>
          <p className="mt-0"><strong> { t('action_permanent') } </strong></p>
        </Stack>
      </Stack>
      <Form methods={methods} onSubmit={deleteRoleAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="neutral" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="danger" type="submit" disabled={deleteRoleAPI.isLoading}>
            {deleteRoleAPI.isLoading && <Spinner className="me-2" />}
            { t('delete') }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteRoleForm.propTypes = {
  handleClose: PropTypes.func,
  role: PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  }).isRequired,
};

DeleteRoleForm.defaultProps = {
  handleClose: () => { },
};
