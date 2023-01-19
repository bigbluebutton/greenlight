/* eslint-disable react/jsx-props-no-spreading */
import React from 'react';
import { Placeholder } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function RoundPlaceholder({ size, ...props }) {
  const circleClass = `rounded-circle ${size}-circle`;

  return (
    <Placeholder animation="glow" {...props}>
      <Placeholder className={circleClass} bg="secondary" />
    </Placeholder>
  );
}

RoundPlaceholder.propTypes = {
  size: PropTypes.string.isRequired,
};
