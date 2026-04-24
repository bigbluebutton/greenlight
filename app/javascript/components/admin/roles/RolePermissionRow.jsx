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
          disabled={updateAPI.isLoading}
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
