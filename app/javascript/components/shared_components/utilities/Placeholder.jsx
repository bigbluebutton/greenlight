/* eslint-disable react/jsx-props-no-spreading */
import React from 'react';
import { Placeholder as BootstrapPlaceholder } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Placeholder({ width, size, ...props }) {
  return (
    <BootstrapPlaceholder className="ps-0" animation="glow">
      <BootstrapPlaceholder xs={width} size={size} bg="secondary" {...props} />
    </BootstrapPlaceholder>
  );
}

Placeholder.propTypes = {
  width: PropTypes.number.isRequired,
  size: PropTypes.string.isRequired,
};
