import React from 'react';
import Container from 'react-bootstrap/Container';
import PropTypes from 'prop-types';

export default function BackgroundBuffer({ location }) {
  const bufferSize = () => {
    if (location === '/rooms') {
      return 'background-sm-buffer';
    }

    return 'background-lg-buffer';
  };

  return (
    <Container className={bufferSize()} fluid />
  );
}

BackgroundBuffer.propTypes = {
  location: PropTypes.string.isRequired,
};
