import React from 'react';
import { Card, Placeholder } from 'react-bootstrap';

export default function RoomCardPlaceHolder() {
  return (
    <Card id="room-card" border="light">
      <Card.Body>
        <Placeholder as={Card.Title} animation="glow" className="mb-3">
          <Placeholder style={{ height: '65px', width: '65px', 'border-radius': '10%' }} />
        </Placeholder>
        <Placeholder as={Card.Title} animation="glow">
          <Placeholder xs={5} size="sm" />
        </Placeholder>
        <Placeholder as={Card.Text} animation="glow">
          <Placeholder xs={4} size="xs" /> <Placeholder xs={6} size="xs" />
          <Placeholder xs={2} size="xs" />
        </Placeholder>
        <hr />
        <Placeholder.Button variant="brand-outline" className="float-end" animation="glow"> Start</Placeholder.Button>
      </Card.Body>
    </Card>
  );
}
