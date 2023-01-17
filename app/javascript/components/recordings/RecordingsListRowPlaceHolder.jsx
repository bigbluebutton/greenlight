import React from 'react';
import { Stack } from 'react-bootstrap';
import Placeholder from '../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../shared_components/utilities/RoundPlaceholder';

export default function RecordingsListRowPlaceHolder() {
  return (
    <tr>
      <td colSpan={12} className="border-0">
        <Stack direction="horizontal">
          <RoundPlaceholder radius="35px" className="ms-1 me-3 my-3" />
          <Stack>
            <Placeholder width={12} size="xlg" className="my-3" />
          </Stack>
        </Stack>
      </td>
    </tr>
  );
}
