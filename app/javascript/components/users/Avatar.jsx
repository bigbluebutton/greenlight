import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function Avatar({ radius }) {
  const currentUser = useAuth();
  return (
    <Image src={currentUser?.avatar} roundedCircle="true" width={radius} height={radius} />
  );
}

Avatar.propTypes = {
  radius: PropTypes.number.isRequired,
};
