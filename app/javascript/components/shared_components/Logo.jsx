import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Logo({ className }) {
  const { data: brandingImage } = useSiteSetting('BrandingImage');

  return (
    <Image
      src={brandingImage}
      className={className}
      alt="CompanyLogo"
    />
  );
}

Logo.propTypes = {
  className: PropTypes.string,
};

Logo.defaultProps = {
  className: 'brand-image',
};
