import React from 'react';
import { Row } from 'react-bootstrap';
import ChangePwdForm from './forms/ChangePwdForm';

export default function ChangePassword() {
  return (
    <>
      <Row>
        <h3 className="mb-4"> Change Password </h3>
      </Row>
      <Row>
        <ChangePwdForm />
      </Row>
    </>
  );
}
