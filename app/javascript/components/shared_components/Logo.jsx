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

import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import { useNavigate } from 'react-router-dom';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Logo({ size }) {
  const { isLoading, data: brandingImage } = useSiteSetting('BrandingImage');
  const navigate = useNavigate();

  // Logo can be small or regular size
  const sizeClass = size === 'small'
    ? 'small-logo cursor-pointer'
    : 'logo cursor-pointer position-absolute bottom-0 mx-auto start-0 end-0 text-center';
  // Small Logo is used in Header only and does not require a wrapper
  const sizeWrapperClass = !size ? 'logo-wrapper position-relative d-block mx-auto' : undefined;

  if (isLoading) return <div className={sizeWrapperClass} />;

  return (
    <div className={sizeWrapperClass}>
      <Image
        src={brandingImage}
        className={sizeClass}
        alt="CompanyLogo"
        onClick={() => { navigate('/'); }}
      />
    </div>
  );
}

Logo.propTypes = {
  size: PropTypes.string,
};

Logo.defaultProps = {
  size: '',
};
