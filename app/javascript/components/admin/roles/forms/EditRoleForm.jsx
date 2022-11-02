import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { yupResolver } from '@hookform/resolvers/yup';
import {
  editRoleFormConfigRoleName, validationSchemaRoomLimit, editRoleFormFieldsRoomLimit, editRoleFormFieldsRoleName,
} from '../../../../helpers/forms/EditRoleFormHelpers';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';
import Spinner from '../../../shared_components/utilities/Spinner';
import useUpdateRole from '../../../../hooks/mutations/admin/roles/useUpdateRole';
import Modal from '../../../shared_components/modals/Modal';
import DeleteRoleForm from './DeleteRoleForm';
import useUpdateRolePermission from '../../../../hooks/mutations/admin/role_permissions/useUpdateRolePermissions';
import useRoomConfigs from '../../../../hooks/queries/rooms/useRoomConfigs';
import useRolePermissions from '../../../../hooks/queries/admin/role_permissions/useRolePermissions';
import RolePermissionRow from '../RolePermissionRow';
import { useAuth } from '../../../../contexts/auth/AuthProvider';

export default function EditRoleForm({ role }) {
  const { t } = useTranslation();
  const methodsRoleName = useForm(editRoleFormConfigRoleName);
  const updateRoleAPI = useUpdateRole(role.id);
  const updateRolePermission = () => useUpdateRolePermission();
  const updateAPI = updateRolePermission();
  const fieldsRoleName = editRoleFormFieldsRoleName;
  const fieldsRoomLimit = editRoleFormFieldsRoomLimit;
  const roomConfigs = useRoomConfigs();
  const { data: rolePermissions, isLoading: rolePermissionsIsLoading } = useRolePermissions(role.id);
  const currentUser = useAuth();
  const editRoleFormConfigRoomLimit = {
    mode: 'onBlur',
    defaultValues: { role_id: role.id, name: 'RoomLimit' },
    resolver: yupResolver(validationSchemaRoomLimit),
  };
  const methodsRoomLimit = useForm(editRoleFormConfigRoomLimit);

  useEffect(
    () => {
      methodsRoleName.setValue('name', role.name);
    },
    [role.name],
  );

  function deleteRoleButton() {
    if (role.name === 'User' || role.name === 'Administrator' || role.name === 'Guest') {
      return null;
    }
    return (
      <div>
        <Modal
          modalButton={<Button variant="delete" className="float-end"> { t('admin.roles.delete_role') } </Button>}
          title={t('admin.roles.delete_role')}
          body={<DeleteRoleForm role={role} />}
        />
      </div>
    );
  }

  if (roomConfigs.isLoading || rolePermissionsIsLoading) return <Spinner />;
  fieldsRoomLimit.value.placeHolder = rolePermissions.RoomLimit;

  return (
    <div>
      <Stack>
        <Form methods={methodsRoleName} onBlur={(e) => updateRoleAPI.mutate({ name: e.target.value })}>
          <FormControl field={fieldsRoleName.name} type="text" />
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

          <Form methods={methodsRoomLimit} onBlur={methodsRoomLimit.handleSubmit(updateAPI.mutate)}>
            <Stack direction="horizontal">
              <div className="text-muted me-auto">
                Room Limit
              </div>
              <div className="float-end">
                <FormControl field={fieldsRoomLimit.value} noLabel className="room-limit" type="number" />
              </div>
            </Stack>
          </Form>
        </Stack>
        {
          deleteRoleButton()
        }
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
