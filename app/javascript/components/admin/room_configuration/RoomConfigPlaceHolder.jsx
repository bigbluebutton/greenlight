import React from 'react';
import {
  Col, Row, Stack,
} from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function RoomConfigPlaceHolder() {
  return (
    <div className="p-4">
      <Row>
        <Col md="9">
          <Stack>
            <Placeholder width={6} size="md" />
            <Placeholder width={12} size="xlg" />
          </Stack>
        </Col>
      </Row>
    </div>
  );
}
