import React from 'react';
import {
  Col, Row,
} from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function EditRolePlaceHolder() {
  return (
    <Row className="py-3 d-flex">
      <Col>
        <Placeholder width={8} size="md" className="me-2" />
      </Col>
      <Col md="1">
        <Placeholder width={5} size="md" className="me-2" />
      </Col>
    </Row>
  );
}
