import React from 'react';
import { Stack } from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../../shared_components/utilities/RoundPlaceholder';

export default function RecordingsListRowPlaceHolder() {
  return (
    <tr>
      <td className="border-0 py-2 xl-td-placeholder">
        <Stack direction="horizontal">
          <RoundPlaceholder size="small" className="ms-1 me-3 mt-1" />
          <Stack>
            <Placeholder width={10} size="md" />
            <Placeholder width={10} size="md" />
          </Stack>
        </Stack>
      </td>
      <td className="border-0 py-3 xl-td-placeholder">
        <Placeholder width={10} size="md" />
      </td>
      <td className="border-0 py-3 md-td-placeholder">
        <Placeholder width={6} size="md" />
      </td>
    </tr>
  );
}
