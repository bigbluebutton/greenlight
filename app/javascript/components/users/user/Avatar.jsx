import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import { Placeholder } from 'react-bootstrap';

export default function Avatar({ avatar, radius, className }) {

  return (
    <React.Suspense fallback={(
      <Placeholder animation="glow" className="mb-3">
        <Placeholder style={{ height: radius, width: radius, 'border-radius': '50%' }} />
      </Placeholder>
    )}
    >
      <Image src={avatar} roundedCircle="true" width={radius} height={radius} className={className} />
    </React.Suspense>
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
