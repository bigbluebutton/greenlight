import React from 'react';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function ManageUsersInvitedRowPlaceHolder() {
  return (
    <tr>
      <td className="border-0 py-2 lg-td-placeholder">
        <Placeholder width={10} size="md" />
      </td>
      <td className="border-0 py-3 lg-td-placeholder">
        <Placeholder width={10} size="md" />
      </td>
      <td className="border-0 py-3 sm-td-placeholder">
        <Placeholder width={5} size="md" />
      </td>
    </tr>
  );
}
