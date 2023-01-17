import React from 'react';
import {
  Col, Row, Stack,
} from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function RoomConfigPlaceHolder() {
  return (
    <div className="p-4">
      <Row className="mb-4">
        <Col md="9">
          <Stack>
            <Placeholder width={3} size="md" className="me-2" />
            <Placeholder width={12} size="xlg" className="me-2" />
          </Stack>
        </Col>
      </Row>
    </div>
  );
}
