import React from 'react';
import { Spinner as BootstrapSpinner } from 'react-bootstrap';

export default function Spinner() {
  return (
    <BootstrapSpinner
      className="mx-1"
      as="span"
      animation="border"
      role="status"
      aria-hidden="true"
    />
  );
}
