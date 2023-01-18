import React from 'react';
import { Placeholder } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function RoundPlaceholder({ radius, className }) {
  return (
    <Placeholder animation="glow">
      <Placeholder style={{ height: radius, width: radius, borderRadius: '50%' }} className={className} bg="secondary" />
    </Placeholder>
  );
}

RoundPlaceholder.propTypes = {
  radius: PropTypes.number.isRequired,
  className: PropTypes.string,
};

RoundPlaceholder.defaultProps = {
  className: '',
};
