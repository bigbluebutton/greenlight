import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';

export default function Avatar({ avatar, radius, className }) {
  return (
    <Image src={avatar} roundedCircle="true" width={radius} height={radius} className={className} />
  );
}

Avatar.propTypes = {
  avatar: PropTypes.string.isRequired,
  radius: PropTypes.number.isRequired,
  className: PropTypes.string,
};

Avatar.defaultProps = {
  className: '',
};
