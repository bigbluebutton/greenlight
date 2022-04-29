import React from 'react';
import { Col, Row } from 'react-bootstrap';
import SetAvatar from './SetAvatar';
import UpdateUserForm from '../forms/UpdateUserForm';

export default function AccountInfo() {
  return (
    <Row>
      <Col>
        <h3 className="mb-4"> Update Your Account Info </h3>
        <UpdateUserForm />
      </Col>
      <Col>
        <SetAvatar />
      </Col>
    </Row>
  );
}
