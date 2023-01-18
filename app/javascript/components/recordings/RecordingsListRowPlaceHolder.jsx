import React from 'react';
import { Stack } from 'react-bootstrap';
import Placeholder from '../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../shared_components/utilities/RoundPlaceholder';

export default function RecordingsListRowPlaceHolder() {
  return (
    <tr>
      <td className="border-0 pt-3 xl-td-placeholder">
        <Stack direction="horizontal">
          <RoundPlaceholder radius="35px" className="ms-1 me-3" />
          <Stack>
            <Placeholder width={10} size="lg" />
            <Placeholder width={10} size="md" />
          </Stack>
        </Stack>
      </td>
      <td className="border-0 pt-4 sm-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
      <td className="border-0 pt-4 sm-td-placeholder">
        <Placeholder width={4} size="md" />
      </td>
      <td className="border-0 pt-4 md-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
      <td className="border-0 pt-4 xl-td-placeholder">
        <Placeholder width={10} size="md" />
      </td>
    </tr>
  );
}
