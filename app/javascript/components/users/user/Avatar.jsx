// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
