// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';
import useUpdateRole from '../../../../hooks/mutations/admin/roles/useUpdateRole';
import Modal from '../../../shared_components/modals/Modal';
import DeleteRoleForm from './DeleteRoleForm';
import useUpdateRolePermission from '../../../../hooks/mutations/admin/role_permissions/useUpdateRolePermissions';
import useRoomConfigs from '../../../../hooks/queries/rooms/useRoomConfigs';
import useRolePermissions from '../../../../hooks/queries/admin/role_permissions/useRolePermissions';
import RolePermissionRow from '../RolePermissionRow';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import RolePermissionRowPlaceHolder from '../RolePermissionRowPlaceHolder';
import useEditRoleNameForm from '../../../../hooks/forms/admin/roles/useEditRoleNameForm';
import useEditRoleLimitForm from '../../../../hooks/forms/admin/roles/useEditRoleLimitForm';

export default function EditRoleForm({ role }) {
  const { t } = useTranslation();
  const currentUser = useAuth();

  const { isLoading: isLoadingRoomConfigs, data: roomConfigs } = useRoomConfigs();
  const { isLoading, data: rolePermissions } = useRolePermissions(role?.id);

  const updateRoleAPI = useUpdateRole(role?.id);
  const updatePermissionAPI = useUpdateRolePermission();

  const { methods: methodsName, fields: fieldsName } = useEditRoleNameForm({ defaultValues: { name: role?.name } });

  const {
    methods: methodsLimit,
    fields: fieldsLimit,
  } = useEditRoleLimitForm({ defaultValues: { role_id: role?.id, name: 'RoomLimit' } });

  function deleteRoleButton() {
    if (role?.name === 'User' || role?.name === 'Administrator' || role?.name === 'Guest') {
      return null;
    }
    return (
      <div>
        <Modal
          modalButton={<Button variant="delete" className="float-end my-4"> { t('admin.roles.delete_role') } </Button>}
          body={<DeleteRoleForm role={role} />}
        />
      </div>
    );
  }

  return (
    <div id="edit-role-form">
      {
        isLoadingRoomConfigs || isLoading
          ? (
          // eslint-disable-next-line react/no-array-index-key
            [...Array(9)].map((val, idx) => <RolePermissionRowPlaceHolder key={idx} />)
          )
          : (
            <div>
              <Form methods={methodsName} onBlur={(e) => updateRoleAPI.mutate({ name: e.target.value })}>
                <FormControl field={fieldsName.name} type="text" />
              </Form>
              <RolePermissionRow
                permissionName="CreateRoom"
                description={t('admin.roles.edit.create_room')}
                roleId={role?.id}
                defaultValue={rolePermissions?.CreateRoom === 'true'}
              />
              <RolePermissionRow
                permissionName="ApiCreateRoom"
                description={t('admin.roles.edit.api_create_room')}
                roleId={role?.id}
                defaultValue={rolePermissions?.ApiCreateRoom === 'true'}
              />
              {['optional', 'default_enabled'].includes(roomConfigs?.record) && (
              <RolePermissionRow
                permissionName="CanRecord"
                description={t('admin.roles.edit.record')}
                roleId={role?.id}
                defaultValue={rolePermissions?.CanRecord === 'true'}
              />
              )}
              <RolePermissionRow
                permissionName="ManageUsers"
                description={t('admin.roles.edit.manage_users')}
                roleId={role?.id}
                defaultValue={rolePermissions?.ManageUsers === 'true'}
              />
              <RolePermissionRow
                permissionName="ManageRooms"
                description={t('admin.roles.edit.manage_rooms')}
                roleId={role?.id}
                defaultValue={rolePermissions?.ManageRooms === 'true'}
              />
              <RolePermissionRow
                permissionName="ManageRecordings"
                description={t('admin.roles.edit.manage_recordings')}
                roleId={role?.id}
                defaultValue={rolePermissions?.ManageRecordings === 'true'}
              />
              <RolePermissionRow
                permissionName="ManageSiteSettings"
                description={t('admin.roles.edit.manage_site_settings')}
                roleId={role?.id}
                defaultValue={rolePermissions?.ManageSiteSettings === 'true'}
              />
              {/* Don't show ManageRoles if current_user is editing their own role */}
              {(currentUser.role.id !== role?.id) && (
              <RolePermissionRow
                permissionName="ManageRoles"
                description={t('admin.roles.edit.manage_roles')}
                roleId={role?.id}
                defaultValue={rolePermissions?.ManageRoles === 'true'}
              />
              )}
              <RolePermissionRow
                permissionName="SharedList"
                description={t('admin.roles.edit.shared_list')}
                roleId={role?.id}
                defaultValue={rolePermissions?.SharedList === 'true'}
              />

              <Form methods={methodsLimit} onBlur={methodsLimit.handleSubmit(updatePermissionAPI.mutate)}>
                <Stack direction="horizontal">
                  <div className="text-muted me-auto">
                    {t('admin.roles.edit.room_limit')}
                  </div>
                  <div>
                    <FormControl
                      field={fieldsLimit.value}
                      defaultValue={rolePermissions?.RoomLimit}
                      noLabel
                      className="room-limit float-end"
                      type="number"
                    />
                  </div>
                </Stack>
              </Form>
            </div>
          )
}

      {
        deleteRoleButton()
      }
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
