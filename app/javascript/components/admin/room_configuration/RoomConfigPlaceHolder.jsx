import React from 'react';
import {
  Col, Row, Stack,
} from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function RoomConfigPlaceHolder() {
  return (
    <Row className="mb-4">
      <Col md="9">
        <Stack>
          <Placeholder width={8} size="md" className="me-2" />
          <Placeholder width={8} size="lg" className="me-2" />
        </Stack>
      </Col>
      <Col md="3">
        <Placeholder width={5} size="md" className="me-2" />
      </Col>
    </Row>
  );
}
