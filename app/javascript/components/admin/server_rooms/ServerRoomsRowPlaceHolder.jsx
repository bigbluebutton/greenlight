import React from 'react';
import { Placeholder } from 'react-bootstrap';

export default function ServerRoomsRowPlaceHolder() {
  return (
    <tr>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={8} size="md" className="me-2" />
        </Placeholder>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={10} size="md" className="me-2" />
        </Placeholder>
      </td>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={6} size="md" className="me-2" />
        </Placeholder>
      </td>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={6} size="md" className="me-2" />
        </Placeholder>
      </td>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={6} size="md" className="me-2" />
        </Placeholder>
      </td>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={6} size="md" className="me-2" />
        </Placeholder>
      </td>
    </tr>
  );
}
