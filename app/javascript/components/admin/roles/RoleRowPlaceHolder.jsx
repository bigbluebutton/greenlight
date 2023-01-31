import React from 'react';
import { Stack } from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../../shared_components/utilities/RoundPlaceholder';

export default function RoleRowPlaceHolder() {
  return (
    <tr className="align-middle border border-2 cursor-pointer">
      <td colSpan={12} className="py-4">
        <Stack direction="horizontal">
          <RoundPlaceholder size="xs" className="mx-1" />
          <Stack>
            <Placeholder width={3} size="lg" />
          </Stack>
        </Stack>
      </td>
    </tr>
  );
}
