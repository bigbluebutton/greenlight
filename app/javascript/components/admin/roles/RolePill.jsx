import React from 'react';
import { Badge } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function RolePill({ role }) {
  const { name, color } = role;

  return (
    <Badge pill ref={(el) => el && el.style.setProperty('background-color', color, 'important')}>
      {name}
    </Badge>
  );
}

RolePill.propTypes = {
  role: PropTypes.shape({
    name: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  }).isRequired,
};
