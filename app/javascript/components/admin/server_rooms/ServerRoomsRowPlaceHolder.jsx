import React from 'react';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function ServerRoomsRowPlaceHolder() {
  return (
    <tr>
      <td className="border-0">
        <Placeholder width={8} size="md" className="me-2" />
        <Placeholder width={10} size="md" className="me-2" />
      </td>
      <td className="border-0">
        <Placeholder width={6} size="md" className="me-2" />
      </td>
      <td className="border-0">
        <Placeholder width={6} size="md" className="me-2" />
      </td>
      <td className="border-0">
        <Placeholder width={6} size="md" className="me-2" />
      </td>
      <td className="border-0">
        <Placeholder width={6} size="md" className="me-2" />
      </td>
      <td className="border-0" />
    </tr>
  );
}
