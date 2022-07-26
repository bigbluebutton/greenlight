import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { editRoleFormConfig, editRoleFormFields } from '../../../helpers/forms/EditRoleFormHelpers';
import Form from '../Form';
import FormControl from '../FormControl';
import Spinner from '../../shared/stylings/Spinner';
import useUpdateRole from '../../../hooks/mutations/admin/roles/useUpdateRole';
import Modal from '../../shared/Modal';
import DeleteRoleForm from '../DeleteRoleForm';

export default function EditRoleForm({ role }) {
  const methods = useForm(editRoleFormConfig);
  const updateRoleAPI = useUpdateRole(role.id);

  const { defaultValues } = editRoleFormConfig;
  defaultValues.name = role.name;
  const fields = editRoleFormFields;
  fields.name.placeHolder = defaultValues.name;

  return (
    <Form methods={methods} onSubmit={updateRoleAPI.mutate}>
      <FormControl field={fields.name} type="text" />
      <Stack className="mt-1 float-end" gap={2} direction="horizontal">
        <Modal
          modalButton={<Button className="danger-light-button"> Delete Role </Button>}
          title="Delete Role"
          body={<DeleteRoleForm role={role} />}
        />
        <Button
          variant="outline-primary"
          onClick={() => methods.reset(defaultValues)}
        >
          Cancel
        </Button>
        <Button variant="brand" type="submit" disabled={updateRoleAPI.isLoading}>
          Update
          {updateRoleAPI.isLoading && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}

EditRoleForm.propTypes = {
  role: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    color: PropTypes.string,
  }).isRequired,
};
