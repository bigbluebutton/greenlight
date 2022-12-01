import React from 'react';
import { Placeholder as BootstrapPlaceholder } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Placeholder({ width, size, className }) {
  return (
    <BootstrapPlaceholder className="ps-0" animation="glow">
      <BootstrapPlaceholder xs={width} size={size} className={className} bg="secondary" />
    </BootstrapPlaceholder>
  );
}

Placeholder.propTypes = {
  width: PropTypes.number.isRequired,
  size: PropTypes.string.isRequired,
  className: PropTypes.string,
};

Placeholder.defaultProps = {
  className: '',
};
