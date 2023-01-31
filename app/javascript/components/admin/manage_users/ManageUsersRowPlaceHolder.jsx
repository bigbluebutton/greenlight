import React from 'react';
import { Stack } from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../../shared_components/utilities/RoundPlaceholder';

export default function ManageUsersRowPlaceHolder() {
  return (
    <tr>
      <td className="border-0 py-2 lg-td-placeholder">
        <Stack direction="horizontal">
          <RoundPlaceholder size="small" className="ms-1 me-3 mt-1" />
          <Stack>
            <Placeholder width={10} size="md" />
            <Placeholder width={10} size="md" />
          </Stack>
        </Stack>
      </td>
      <td className="border-0 py-3 lg-td-placeholder">
        <Placeholder width={10} size="md" />
      </td>
      <td className="border-0 py-3 sm-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
    </tr>
  );
}
