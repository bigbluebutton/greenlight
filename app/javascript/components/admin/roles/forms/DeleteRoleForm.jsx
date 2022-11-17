import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useDeleteRole from '../../../../hooks/mutations/admin/roles/useDeleteRole';

export default function DeleteRoleForm({ role, handleClose }) {
  const { t } = useTranslation();
  const deleteRoleAPI = useDeleteRole({ role, onSettled: handleClose });
  const methods = useForm();

  return (
    <>
      <p className="text-center">{ t('admin.roles.are_you_sure_delete_role') }</p>
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
