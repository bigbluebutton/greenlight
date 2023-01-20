import React from 'react';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function ServerRoomsRowPlaceHolder() {
  return (
    <tr>
      <td className="border-0 py-2 xl-td-placeholder">
        <Placeholder width={6} size="md" />
        <Placeholder width={10} size="lg" />
      </td>
      <td className="border-0 py-4 lg-td-placeholder">
        <Placeholder width={8} size="md" />
      </td>
      <td className="border-0 py-4 md-td-placeholder">
        <Placeholder width={12} size="md" />
      </td>
      <td className="border-0 py-4 sm-td-placeholder">
        <Placeholder width={2} size="md" />
      </td>
      <td className="border-0 py-4 sm-td-placeholder">
        <Placeholder width={10} size="md" />
      </td>
    </tr>
  );
}
