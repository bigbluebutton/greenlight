import React from 'react';
import PropTypes from 'prop-types';
import { Button, Container } from 'react-bootstrap';

export default function EditUser({ setEdit }) {
  return (
    <Container>
      <h1> Admin Edit User Componenet </h1>
      <Button onClick={() => setEdit(false)}>
        Back
      </Button>
    </Container>
  );
}

EditUser.propTypes = {
  setEdit: PropTypes.func.isRequired,
};
