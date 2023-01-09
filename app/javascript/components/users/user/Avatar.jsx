/* eslint-disable react/jsx-no-bind */
import React, { useState } from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import { Placeholder } from 'react-bootstrap';

export default function Avatar({ avatar, radius, className }) {
  const [isLoaded, setIsLoaded] = useState(false);

  function onLoad() {
    setIsLoaded(true);
  }

  return (
    <>
      <Image
        src={avatar}
        roundedCircle="true"
        width={radius}
        height={radius}
        className={className}
        style={{ display: isLoaded ? '' : 'none' }}
        onLoad={onLoad}
      />
      {!isLoaded && (
      <Placeholder animation="glow" className="mb-3">
        <Placeholder style={{ height: radius, width: radius, borderRadius: '50%' }} />
      </Placeholder>
      )}
    </>
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
