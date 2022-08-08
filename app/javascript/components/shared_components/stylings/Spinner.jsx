import React from 'react';
import { Spinner as BootstrapSpinner } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Spinner({
  animation, size, variant, className,
}) {
  return (
    <BootstrapSpinner
      className={className}
      as="span"
      animation={animation}
      role="status"
      aria-hidden="true"
      variant={variant}
      size={size}
    />
  );
}

Spinner.defaultProps = {
  className: '',
  animation: 'border',
  size: 'sm',
  variant: '',
};

Spinner.propTypes = {
  animation: PropTypes.string,
  size: PropTypes.string,
  variant: PropTypes.string,
  className: PropTypes.string,
};
