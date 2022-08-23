import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { editRoleFormConfig, editRoleFormFields } from '../../../../helpers/forms/EditRoleFormHelpers';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';
import Spinner from '../../../shared_components/utilities/Spinner';
import useUpdateRole from '../../../../hooks/mutations/admin/roles/useUpdateRole';
import Modal from '../../../shared_components/modals/Modal';
import DeleteRoleForm from './DeleteRoleForm';
import useUpdateRolePermission from '../../../../hooks/mutations/admin/role_permissions/useUpdateRolePermissions';
import useRoomConfigs from '../../../../hooks/queries/admin/room_configuration/useRoomConfigs';
import useRolePermissions from '../../../../hooks/queries/admin/role_permissions/useRolePermissions';

export default function EditRoleForm({ role }) {
  const methods = useForm(editRoleFormConfig);
  const updateRoleAPI = useUpdateRole(role.id);
  const updateRolePermission = useUpdateRolePermission();
  const { defaultValues } = editRoleFormConfig;
  defaultValues.name = role.name;
  const fields = editRoleFormFields;
  fields.name.placeHolder = defaultValues.name;
  const roomConfigs = useRoomConfigs();
  const rolePermissions = useRolePermissions();
  console.log(role);
  if (roomConfigs.isLoading || rolePermissions.isLoading) return <Spinner />;
  return (
    <div>
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
      {/* TODO: Put into row component & classname scss */}
      {(roomConfigs.isLoading || rolePermissions.isLoading || roomConfigs.data.record === 'optional') && (
        <div className="room-settings-row text-muted py-3 d-flex">
          { /* eslint-disable-next-line jsx-a11y/label-has-associated-control */ }
          <label className="form-check-label me-auto" htmlFor="test">
            Allow users with this role to record their meetings
          </label>
          <div className="form-switch">
            <input
              id="test"
              className="form-check-input fs-5"
              type="checkbox"
              defaultChecked={rolePermissions.data.CanRecord === 'true'}
              onClick={(event) => {
                // TODO: Currently using role_id and name, review this
                updateRolePermission.mutate({ role_id: role.id, name: 'CanRecord', value: event.target.checked });
              }}
            />
          </div>
        </div>
      )}
    </div>
  );
}

EditRoleForm.propTypes = {
  role: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    color: PropTypes.string,
  }).isRequired,
};
