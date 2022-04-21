import React from 'react';
import { Card, Placeholder } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCopy } from '@fortawesome/free-regular-svg-icons';
import { faChalkboardUser } from '@fortawesome/free-solid-svg-icons';

export default function RoomPlaceHolder() {
  return (
    <Card className="rooms-placeholder" style={{ height: '19rem', overflow: 'hidden' }} border="light">
      <Card.Body style={{ maxHeight: '12rem', overflow: 'hidden' }} className="room-placeholder-top pb-0">
        <FontAwesomeIcon icon={faChalkboardUser} size="3x" className="mb-4" />
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
        <FontAwesomeIcon icon={faCopy} size="lg" />
        <Placeholder.Button variant="outline-secondary" className="float-end" animation="glow"> Start</Placeholder.Button>
      </Card.Body>
    </Card>
  );
}
