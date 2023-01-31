import React from 'react';
import PropTypes from 'prop-types';
import useUpdateRolePermission from '../../../hooks/mutations/admin/role_permissions/useUpdateRolePermissions';

export default function RolePermissionRow({
  permissionName, description, roleId, defaultValue,
}) {
  const updateAPI = useUpdateRolePermission();

  return (
    <div className="text-muted py-3 d-flex">
      <label className="form-check-label me-auto" htmlFor={permissionName}>
        {description}
      </label>
      <div className="form-switch">
        <input
          id={permissionName}
          className="form-check-input fs-5"
          type="checkbox"
          defaultChecked={defaultValue}
          onClick={(event) => {
            updateAPI.mutate({ role_id: roleId, name: permissionName, value: event.target.checked });
          }}
        />
      </div>
    </div>
  );
}

RolePermissionRow.propTypes = {
  permissionName: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  defaultValue: PropTypes.bool.isRequired,
  roleId: PropTypes.string.isRequired,
};
