import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Logo({ size }) {
  const { data: brandingImage } = useSiteSetting('BrandingImage');

  const sizeClass = `${size}-logo`;

  return (
    <Image
      src={brandingImage}
      className={sizeClass}
      alt="CompanyLogo"
    />
  );
}

Logo.propTypes = {
  size: PropTypes.oneOf(['small', 'medium', 'large']),
};

Logo.defaultProps = {
  size: 'small',
};
