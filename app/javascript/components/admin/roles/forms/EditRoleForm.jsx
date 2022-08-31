import React, { useEffect } from 'react';
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
import RolePermissionRow from '../RolePermissionRow';

export default function EditRoleForm({ role }) {
  const methods = useForm(editRoleFormConfig);
  const updateRoleAPI = useUpdateRole(role.id);
  const updateRolePermission = () => useUpdateRolePermission();
  const { defaultValues } = editRoleFormConfig;
  const fields = editRoleFormFields;
  fields.name.placeHolder = defaultValues.name;
  const roomConfigs = useRoomConfigs();
  const rolePermissions = useRolePermissions(role.id);

  useEffect(
    () => {
      methods.setValue('name', role.name);
    },
    [role.name],
  );

  if (roomConfigs.isLoading || rolePermissions.isLoading) return <Spinner />;

  return (
    <div>
      <Stack>
        <Form methods={methods} onBlur={(e) => updateRoleAPI.mutate({ name: e.target.value })}>
          <FormControl field={fields.name} type="text" />
        </Form>
        {(roomConfigs.isLoading || rolePermissions.isLoading || roomConfigs.data.record === 'optional') && (
          <Stack>
            <RolePermissionRow
              permissionName="CanRecord"
              description="Allow users with this role to record their meetings"
              roleId={role.id}
              defaultValue={rolePermissions.data.CanRecord === 'true'}
              updateMutation={updateRolePermission}
            />
          </Stack>
        )}
        <div>
          <Modal
            modalButton={<Button className="float-end danger-light-button"> Delete Role </Button>}
            title="Delete Role"
            body={<DeleteRoleForm role={role} />}
          />
        </div>
      </Stack>
    </div>
  );
}

EditRoleForm.propTypes = {
  role: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    color: PropTypes.string,
  }).isRequired,
};
