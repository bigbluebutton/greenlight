import React from 'react';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function ServerRoomsRowPlaceHolder() {
  return (
    <tr>
      <td colSpan={12} className="border-0 pe-3">
        <Placeholder width={2} size="lg" className="mb-1" />
        <Placeholder width={12} size="xlg" />
      </td>
    </tr>
  );
}
