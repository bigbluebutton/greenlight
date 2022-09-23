import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useDeleteRole from '../../../../hooks/mutations/admin/roles/useDeleteRole';

export default function DeleteRoleForm({ role, handleClose }) {
  const deleteRoleAPI = useDeleteRole({ role, onSettled: handleClose });
  const methods = useForm();

  return (
    <>
      <p className="text-center"> Are you sure you want to delete role <strong>{role.name}</strong>?</p>
      <Form methods={methods} onSubmit={deleteRoleAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="brand-outline" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={deleteRoleAPI.isLoading}>
            Delete
            {deleteRoleAPI.isLoading && <Spinner />}
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
