/* eslint-disable react/jsx-props-no-spreading */
/* eslint-disable react/jsx-no-bind */
import React, { useState } from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import RoundPlaceholder from '../../shared_components/utilities/RoundPlaceholder';

export default function Avatar({ avatar, size, ...props }) {
  const [isLoaded, setIsLoaded] = useState(false);
  const avatarSizeClass = `${size}-circle`;

  function onLoad() {
    setIsLoaded(true);
  }

  return (
    <div {...props}>
      <Image
        src={avatar}
        roundedCircle="true"
        className={avatarSizeClass}
        style={{ display: isLoaded ? '' : 'none' }}
        onLoad={onLoad}
      />
      {!isLoaded && (
        <RoundPlaceholder size={size} />
      )}
    </div>
  );
}

Avatar.propTypes = {
  avatar: PropTypes.string.isRequired,
  size: PropTypes.string.isRequired,
};
