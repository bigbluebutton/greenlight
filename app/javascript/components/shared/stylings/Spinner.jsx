import React from 'react';
import { Spinner as BootstrapSpinner } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Spinner({ className }) {
  return (
    <BootstrapSpinner
      className={className}
      as="span"
      animation="border"
      role="status"
      aria-hidden="true"
    />
  );
}

Spinner.propTypes = {
  className: PropTypes.string,
};

Spinner.defaultProps = {
  className: '',
};
