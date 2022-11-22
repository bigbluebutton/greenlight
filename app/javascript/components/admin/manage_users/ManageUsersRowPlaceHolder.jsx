import React from 'react';
import { Placeholder } from 'react-bootstrap';

export default function RecordingsListRowPlaceHolder() {
  return (
    <tr>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={8} size="md" className="me-2" bg="secondary" />
        </Placeholder>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={10} size="md" className="me-2" bg="secondary" />
        </Placeholder>
      </td>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={8} size="md" className="me-2" bg="secondary" />
        </Placeholder>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={10} size="md" className="me-2" bg="secondary" />
        </Placeholder>
      </td>
      <td>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={8} size="md" className="me-2" bg="secondary" />
        </Placeholder>
        <Placeholder className="ps-0" animation="glow">
          <Placeholder xs={10} size="md" className="me-2" bg="secondary" />
        </Placeholder>
      </td>
    </tr>
  );
}
