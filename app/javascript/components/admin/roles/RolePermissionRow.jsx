import React from 'react';
import PropTypes from 'prop-types';

export default function RolePermissionRow({
  permissionName, description, roleId, defaultValue, updateMutation: useUpdateAPI,
}) {
  const updateAPI = useUpdateAPI();
  return (
    <div className="text-muted py-3 d-flex">
      <label className="form-check-label me-auto" htmlFor="checkBox">
        {description}
      </label>
      <div className="form-switch">
        <input
          id="checkBox"
          className="form-check-input fs-5"
          type="checkbox"
          defaultChecked={defaultValue}
          onClick={(event) => {
          // TODO: Currently using roleId and name, review this
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
  updateMutation: PropTypes.func.isRequired,
  roleId: PropTypes.string.isRequired,
};
