import React from 'react';
import PropTypes from 'prop-types';

export default function RoleBadge({ role }) {
  return (
    <>
      <span className="role-color-dot me-2" ref={(el) => el && el.style.setProperty('background-color', role?.color, 'important')} />
      {role?.name}
    </>
  );
}

RoleBadge.propTypes = {
  role: PropTypes.shape({
    name: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  }).isRequired,
};
