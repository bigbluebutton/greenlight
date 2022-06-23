import React from 'react';
import { Card, Placeholder } from 'react-bootstrap';

export default function RoomPlaceHolder() {
  return (
    <Card className="rooms-placeholder" style={{ height: '19rem', overflow: 'hidden' }} border="light">
      <Card.Body style={{ maxHeight: '12rem', overflow: 'hidden' }} className="room-placeholder-top pb-0">
        <Placeholder as={Card.Title} animation="glow">
          <Placeholder xs={12} size="sm" />
        </Placeholder>
        <Placeholder as={Card.Text} animation="glow">
          <Placeholder xs={7} size="xs" /> <Placeholder xs={4} size="xs" /> <Placeholder xs={3} size="xs" />
        </Placeholder>
      </Card.Body>
      <Card.Body style={{ maxHeight: '7rem', overflow: 'hidden' }} className="pt-0">
        <Placeholder as={Card.Text} animation="glow">
          <Placeholder xs={3} size="xs" /> <Placeholder xs={2} size="xs" />
        </Placeholder>
        <hr />
        <Placeholder.Button variant="outline-secondary" className="float-end" animation="glow"> Start</Placeholder.Button>
      </Card.Body>
    </Card>
  );
}
