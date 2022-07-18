import React, { useState } from 'react';
import { Alert, Container, Row } from 'react-bootstrap';
import RegistrationForm from '../../forms/admin/RegistrationForm';

const DUMMY_ROLES_MAP = [
  { name: 'User', suffix: 'users.com' },
  { name: 'Admin', suffix: 'admins.com' },
  { name: 'Teacher', suffix: 'teachers.com' },
  { name: 'Presenter', suffix: 'presenters.com' },
];

export default function Appearance() {
  const [showInfo, setShowInfo] = useState(true);

  return (
    <Container>
      {
        showInfo && (
          <Row className="mt-2 mb-0">
            <Alert variant="light" onClick={() => setShowInfo(false)} dismissible>
              <Alert.Heading>Roles Mapping By Email</Alert.Heading>
              <p className="text-muted">
                Map a user to a role based on their email address suffix.<br />
                Example:<br />
                For a role name=&apos;Teacher&apos; and an email suffix=&apos;teachers.com&apos;.<br />
                A user that signs up with email &apos;teacher@teachers.com&apos; will automatically have the role &apos;Teacher&apos; assigned.
              </p>
            </Alert>
          </Row>
        )
      }
      <Row className="mt-2">
        <RegistrationForm value={DUMMY_ROLES_MAP} />
      </Row>
    </Container>
  );
}
