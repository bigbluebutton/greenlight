import React from 'react';
import { Container, Row } from 'react-bootstrap';
import RegistrationForm from '../../forms/admin/RegistrationForm';

export default function Registration() {
  return (
    <Container className="w-75 mt-2 ms-0">
      <Row className="mb-3">
        <Row> <h6> Role Mapping By Email </h6> </Row>
        <Row> <p className="text-muted"> Map the user to a role using their email.Must be in the format: role1=email1, role2=email2  </p> </Row>
        <Row>
          <RegistrationForm
            mutation={() => ({ mutate: (data) => console.log(data) })}
            value="User=users.com"
          />
        </Row>
      </Row>
    </Container>
  );
}
