import React from 'react';
import {
  Col, Row,
} from 'react-bootstrap';
import Placeholder from '../../shared_components/utilities/Placeholder';

export default function RolesListPlaceHolder() {
  return (
    <Row className="align-middle border border-2 cursor-pointer">
      <Col className="py-4">
        <Placeholder width={5} size="md" className="me-2" />
      </Col>
    </Row>
  );
}
