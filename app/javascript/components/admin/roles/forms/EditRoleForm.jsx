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
import { useAuth } from '../../../../contexts/auth/AuthProvider';

export default function EditRoleForm({ role }) {
  const methods = useForm(editRoleFormConfig);
  const updateRoleAPI = useUpdateRole(role.id);
  const updateRolePermission = () => useUpdateRolePermission();
  const { defaultValues } = editRoleFormConfig;
  const fields = editRoleFormFields;
  fields.name.placeHolder = defaultValues.name;
  const roomConfigs = useRoomConfigs();
  const { data: rolePermissions, isLoading: rolePermissionsIsLoading } = useRolePermissions(role.id);
  const currentUser = useAuth();

  useEffect(
    () => {
      methods.setValue('name', role.name);
    },
    [role.name],
  );

  if (roomConfigs.isLoading || rolePermissionsIsLoading) return <Spinner />;

  return (
    <div>
      <Stack>
        <Form methods={methods} onBlur={(e) => updateRoleAPI.mutate({ name: e.target.value })}>
          <FormControl field={fields.name} type="text" />
        </Form>

        <Stack>
          <RolePermissionRow
            permissionName="CreateRoom"
            description="Can create rooms"
            roleId={role.id}
            defaultValue={rolePermissions.CreateRoom === 'true'}
            updateMutation={updateRolePermission}
          />
          <RolePermissionRow
            permissionName="ManageUsers"
            description="Allow users with this role to manage users"
            roleId={role.id}
            defaultValue={rolePermissions.ManageUsers === 'true'}
            updateMutation={updateRolePermission}
          />
          {(roomConfigs.data.record === 'optional') && (
            <RolePermissionRow
              permissionName="CanRecord"
              description="Allow users with this role to record their meetings"
              roleId={role.id}
              defaultValue={rolePermissions.CanRecord === 'true'}
              updateMutation={updateRolePermission}
            />
          )}
          <RolePermissionRow
            permissionName="ManageRooms"
            description="Allow users with this role to manage server rooms"
            roleId={role.id}
            defaultValue={rolePermissions.ManageRooms === 'true'}
            updateMutation={updateRolePermission}
          />
          <RolePermissionRow
            permissionName="ManageRecordings"
            description="Allow users with this role to manage server recordings"
            roleId={role.id}
            defaultValue={rolePermissions.ManageRecordings === 'true'}
            updateMutation={updateRolePermission}
          />
          <RolePermissionRow
            permissionName="ManageSiteSettings"
            description="Allow users with this role to manage site settings"
            roleId={role.id}
            defaultValue={rolePermissions.ManageSiteSettings === 'true'}
            updateMutation={updateRolePermission}
          />
          {/* Don't show ManageRoles if current_user is editing their own role */}
          {(currentUser.role.id !== role.id) && (
          <RolePermissionRow
            permissionName="ManageRoles"
            description="Allow users with this role to edit other roles"
            roleId={role.id}
            defaultValue={rolePermissions.ManageRoles === 'true'}
            updateMutation={updateRolePermission}
          />
          )}
          <RolePermissionRow
            permissionName="SharedList"
            description="Include users with this role in the dropdown for sharing rooms"
            roleId={role.id}
            defaultValue={rolePermissions.SharedList === 'true'}
            updateMutation={updateRolePermission}
          />
        </Stack>

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
